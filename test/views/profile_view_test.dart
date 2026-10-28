import 'dart:async';

import 'package:flowday/controllers/auth_controller.dart';
import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/models/user.dart';
import 'package:flowday/repositories/auth_repository.dart';
import 'package:flowday/repositories/task_repository.dart';
import 'package:flowday/views/login_view.dart';
import 'package:flowday/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  testWidgets('failed logout keeps the profile open and shows the error', (
    tester,
  ) async {
    final authRepository = MockAuthRepository();
    final taskRepository = MockTaskRepository();
    final authEvents = StreamController<String?>.broadcast();
    when(() => authRepository.currentUserId).thenReturn('user-1');
    when(
      () => authRepository.authStateChanges(),
    ).thenAnswer((_) => authEvents.stream);
    when(
      () => authRepository.loadProfile('user-1'),
    ).thenAnswer((_) async => User(id: 'user-1', email: 'ana@example.com'));
    when(
      () => authRepository.signOut(),
    ).thenThrow(StateError('connection unavailable'));

    final authController = AuthController(repository: authRepository);
    final taskController = TaskController(repository: taskRepository);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authController),
          ChangeNotifierProvider.value(value: taskController),
        ],
        child: const MaterialApp(home: ProfileView()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Perfil'), findsOneWidget);

    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    expect(find.text('Perfil'), findsOneWidget);
    expect(find.byType(LoginView), findsNothing);
    expect(find.textContaining('connection unavailable'), findsOneWidget);
    expect(authController.isAuthenticated, isTrue);

    authController.dispose();
    taskController.dispose();
    await authEvents.close();
  });
}
