import 'dart:async';

import 'package:flowday/controllers/auth_controller.dart';
import 'package:flowday/models/user.dart' as app_user;
import 'package:flowday/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late StreamController<String?> authEvents;

  setUp(() {
    repository = MockAuthRepository();
    authEvents = StreamController<String?>.broadcast();
    when(() => repository.currentUserId).thenReturn(null);
    when(
      () => repository.authStateChanges(),
    ).thenAnswer((_) => authEvents.stream);
  });

  tearDown(() async {
    await authEvents.close();
  });

  test(
    'register returns the created profile and authenticated user id',
    () async {
      final profile = app_user.User(
        id: 'user-1',
        email: 'ana@example.com',
        name: 'Ana',
        lastName: 'Silva',
      );
      var currentUserId = 'user-1';
      when(() => repository.currentUserId).thenAnswer((_) => currentUserId);
      when(
        () => repository.register(
          email: 'ana@example.com',
          password: 'secure-password',
          name: 'Ana',
          lastName: 'Silva',
        ),
      ).thenAnswer((_) async {
        currentUserId = 'user-1';
      });
      when(
        () => repository.loadProfile('user-1'),
      ).thenAnswer((_) async => profile);

      final controller = AuthController(repository: repository);
      final registered = await controller.register(
        email: 'ana@example.com',
        password: 'secure-password',
        name: 'Ana',
        lastName: 'Silva',
      );

      expect(registered, isTrue);
      expect(controller.currentUserId, 'user-1');
      expect(controller.user?.fullName, 'Ana Silva');
      expect(controller.isAuthenticated, isTrue);
      expect(controller.isLoading, isFalse);
      controller.dispose();
    },
  );

  test('auth stream change loads the matching app profile', () async {
    final profile = app_user.User(
      id: 'user-2',
      email: 'bia@example.com',
      name: 'Bia',
    );
    when(
      () => repository.loadProfile('user-2'),
    ).thenAnswer((_) async => profile);

    final controller = AuthController(repository: repository);
    authEvents.add('user-2');
    await Future<void>.delayed(Duration.zero);

    expect(controller.currentUserId, 'user-2');
    expect(controller.user?.email, 'bia@example.com');
    controller.dispose();
  });
  test(
    'login failure clears loading and exposes an error that can be cleared',
    () async {
      final loginResult = Completer<void>();
      when(
        () => repository.signIn(
          email: 'ana@example.com',
          password: 'wrong-password',
        ),
      ).thenAnswer((_) => loginResult.future);

      final controller = AuthController(repository: repository);
      final login = controller.login(
        email: 'ana@example.com',
        password: 'wrong-password',
      );

      expect(controller.isLoading, isTrue);
      loginResult.completeError(StateError('invalid credentials'));

      expect(await login, isFalse);
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, contains('invalid credentials'));

      controller.clearError();
      expect(controller.errorMessage, isNull);
      controller.dispose();
    },
  );

  test('profile load error can be retried successfully', () async {
    final profile = app_user.User(
      id: 'user-3',
      email: 'caio@example.com',
      name: 'Caio',
    );
    when(() => repository.currentUserId).thenReturn('user-3');
    var attempts = 0;
    when(() => repository.loadProfile('user-3')).thenAnswer((_) async {
      attempts++;
      if (attempts == 1) throw StateError('network unavailable');
      return profile;
    });

    final controller = AuthController(repository: repository);
    await Future<void>.delayed(Duration.zero);

    expect(controller.user, isNull);
    expect(controller.errorMessage, contains('network unavailable'));
    expect(controller.isLoading, isFalse);
    await controller.retryLoadProfile();
    expect(controller.user?.email, 'caio@example.com');
    expect(controller.errorMessage, isNull);
    controller.dispose();
  });

  test('logout reports failure and keeps the authenticated session', () async {
    when(() => repository.currentUserId).thenReturn('user-logout');
    when(
      () => repository.loadProfile('user-logout'),
    ).thenAnswer((_) async => app_user.User(id: 'user-logout', email: 'a@b.c'));
    when(() => repository.signOut()).thenThrow(StateError('offline'));

    final controller = AuthController(repository: repository);
    await Future<void>.delayed(Duration.zero);

    expect(await controller.logout(), isFalse);
    expect(controller.currentUserId, 'user-logout');
    expect(controller.errorMessage, contains('offline'));
    expect(controller.isLoading, isFalse);
    controller.dispose();
  });

  test('successful logout clears the authenticated session', () async {
    when(() => repository.currentUserId).thenReturn('user-logout');
    when(
      () => repository.loadProfile('user-logout'),
    ).thenAnswer((_) async => app_user.User(id: 'user-logout', email: 'a@b.c'));
    when(() => repository.signOut()).thenAnswer((_) async {});

    final controller = AuthController(repository: repository);
    await Future<void>.delayed(Duration.zero);

    expect(await controller.logout(), isTrue);
    expect(controller.currentUserId, isNull);
    expect(controller.isAuthenticated, isFalse);
    controller.dispose();
  });
}
