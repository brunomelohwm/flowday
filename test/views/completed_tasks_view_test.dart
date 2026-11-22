import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/models/task.dart';
import 'package:flowday/models/task_sync_update.dart';
import 'package:flowday/repositories/task_repository.dart';
import 'package:flowday/views/completed_tasks_view.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCompletedTaskRepository extends Mock implements TaskRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const Task(
        id: 'fallback',
        userId: 'user-1',
        title: 'Fallback',
        description: '',
        priority: Priority.none,
      ),
    );
  });

  testWidgets('completed list shows only completed tasks and can reopen one', (
    tester,
  ) async {
    final repository = MockCompletedTaskRepository();
    final completed = Task(
      id: 'completed',
      userId: 'user-1',
      title: 'Finished report',
      description: '',
      priority: Priority.medium,
      status: TaskStatus.done,
      endDate: DateTime(2026, 11, 2),
    );
    final completedLater = Task(
      id: 'completed-later',
      userId: 'user-1',
      title: 'Finished follow-up',
      description: '',
      priority: Priority.medium,
      status: TaskStatus.done,
      endDate: DateTime(2026, 11, 4),
    );
    const open = Task(
      id: 'open',
      userId: 'user-1',
      title: 'Prepare slides',
      description: '',
      priority: Priority.low,
    );
    when(() => repository.watchTasks('user-1')).thenAnswer(
      (_) => Stream.value(
        TaskSyncUpdate(
          tasks: [completed, completedLater, open],
          hasPendingWrites: false,
        ),
      ),
    );
    when(() => repository.updateTask(any())).thenAnswer((_) async {});

    final controller = TaskController(repository: repository);
    controller.setUserId('user-1');
    await tester.pumpWidget(
      MaterialApp(home: CompletedTasksView(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Finished report'), findsOneWidget);
    expect(find.text('Finished follow-up'), findsOneWidget);
    expect(find.text('Prepare slides'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Finished report')).dy,
      lessThan(tester.getTopLeft(find.text('Finished follow-up')).dy),
    );
    expect(find.text('Prazo mais próximo'), findsOneWidget);

    await tester.tap(find.text('Prazo mais próximo'));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Finished follow-up')).dy,
      lessThan(tester.getTopLeft(find.text('Finished report')).dy),
    );

    await tester.tap(find.text('Reabrir').first);
    await tester.pumpAndSettle();
    final updated =
        verify(() => repository.updateTask(captureAny())).captured.single
            as Task;
    expect(updated.id, 'completed-later');
    expect(updated.status, TaskStatus.todo);

    controller.dispose();
  });

  testWidgets('completed list has a dedicated empty state', (tester) async {
    final repository = MockCompletedTaskRepository();
    when(() => repository.watchTasks('user-1')).thenAnswer(
      (_) => Stream.value(
        TaskSyncUpdate(tasks: const [], hasPendingWrites: false),
      ),
    );
    final controller = TaskController(repository: repository);
    controller.setUserId('user-1');
    await tester.pumpWidget(
      MaterialApp(home: CompletedTasksView(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma tarefa concluída.'), findsOneWidget);
    controller.dispose();
  });
}
