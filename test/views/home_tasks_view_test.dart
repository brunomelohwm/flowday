import 'dart:async';

import 'package:flowday/controllers/auth_controller.dart';
import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/models/task.dart';
import 'package:flowday/models/task_sync_update.dart';
import 'package:flowday/repositories/auth_repository.dart';
import 'package:flowday/repositories/task_repository.dart';
import 'package:flowday/views/home_tasks_view.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockHomeAuthRepository extends Mock implements AuthRepository {}

class MockHomeTaskRepository extends Mock implements TaskRepository {}

void main() {
  testWidgets('home separates completed tasks and exposes both lists', (
    tester,
  ) async {
    final authRepository = MockHomeAuthRepository();
    final taskRepository = MockHomeTaskRepository();
    when(() => authRepository.currentUserId).thenReturn(null);
    when(
      () => authRepository.authStateChanges(),
    ).thenAnswer((_) => const Stream<String?>.empty());

    final today = DateUtils.dateOnly(DateTime.now());
    final openSoon = _task(
      'open-soon',
      'Open soon',
      endDate: today.add(const Duration(days: 1)),
    );
    final openLater = _task(
      'open-later',
      'Open later',
      endDate: today.add(const Duration(days: 2)),
    );
    final completed = _task(
      'completed',
      'Already done',
      status: TaskStatus.done,
      endDate: today,
    );
    when(() => taskRepository.watchTasks('user-1')).thenAnswer(
      (_) => Stream.value(
        TaskSyncUpdate(
          tasks: [openLater, completed, openSoon],
          hasPendingWrites: false,
        ),
      ),
    );

    final authController = AuthController(repository: authRepository);
    final taskController = TaskController(repository: taskRepository);
    taskController.setUserId('user-1');
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authController),
          ChangeNotifierProvider.value(value: taskController),
        ],
        child: MaterialApp(
          home: Scaffold(body: HomeTasksView(controller: taskController)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Open soon'), findsOneWidget);
    expect(find.text('Already done'), findsNothing);
    expect(find.text('2 tarefas no total'), findsOneWidget);

    await tester.tap(find.text('Concluídas'));
    await tester.pumpAndSettle();
    expect(find.text('Tarefas concluídas'), findsOneWidget);
    expect(find.text('Already done'), findsOneWidget);
    expect(find.text('Open soon'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver todos'));
    await tester.pumpAndSettle();
    expect(find.text('Open soon'), findsOneWidget);
    expect(find.text('Open later'), findsOneWidget);
    expect(find.text('Already done'), findsNothing);
    expect(find.text('Prazo mais próximo'), findsOneWidget);

    final soonTop = tester.getTopLeft(find.text('Open soon')).dy;
    final laterTop = tester.getTopLeft(find.text('Open later')).dy;
    expect(soonTop, lessThan(laterTop));

    await tester.tap(find.text('Prazo mais próximo'));
    await tester.pumpAndSettle();
    expect(find.text('Prazo mais distante'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Open later')).dy,
      lessThan(tester.getTopLeft(find.text('Open soon')).dy),
    );

    authController.dispose();
    taskController.dispose();
  });
}

Task _task(
  String id,
  String title, {
  TaskStatus status = TaskStatus.todo,
  DateTime? endDate,
}) => Task(
  id: id,
  userId: 'user-1',
  title: title,
  description: '',
  priority: Priority.none,
  status: status,
  endDate: endDate,
);
