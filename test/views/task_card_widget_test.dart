import 'dart:async';

import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/models/task.dart';
import 'package:flowday/models/task_sync_update.dart';
import 'package:flowday/repositories/task_repository.dart';
import 'package:flowday/widgets/task_card_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCardTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockCardTaskRepository repository;

  setUpAll(() {
    registerFallbackValue(
      const Task(
        id: 'fallback',
        userId: 'fallback',
        title: 'fallback',
        description: '',
        priority: Priority.none,
      ),
    );
  });

  setUp(() {
    repository = MockCardTaskRepository();
    when(() => repository.watchTasks('user-1')).thenAnswer(
      (_) => Stream.value(
        TaskSyncUpdate(tasks: const <Task>[], hasPendingWrites: false),
      ),
    );
    when(() => repository.updateTask(any())).thenAnswer((_) async {});
  });

  for (final status in [TaskStatus.todo, TaskStatus.done]) {
    testWidgets(
      status == TaskStatus.done
          ? 'reopens a completed task without opening the editor'
          : 'completes a task without opening the editor',
      (tester) async {
        final controller = TaskController(repository: repository);
        controller.setUserId('user-1');
        await tester.pump();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TaskCardWidget(
                controller: controller,
                task: Task(
                  id: 'task-1',
                  userId: 'user-1',
                  title: 'Prepare interview',
                  description: '',
                  priority: Priority.medium,
                  status: status,
                ),
              ),
            ),
          ),
        );

        await tester.tap(
          find.text(
            status == TaskStatus.done ? 'Reabrir' : 'Marcar como concluída',
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text(
            status == TaskStatus.done
                ? 'Tarefa reaberta.'
                : 'Tarefa concluída.',
          ),
          findsOneWidget,
        );
        expect(find.text('Título...'), findsNothing);

        final persisted =
            verify(() => repository.updateTask(captureAny())).captured.single
                as Task;
        expect(
          persisted.status,
          status == TaskStatus.done ? TaskStatus.todo : TaskStatus.done,
        );
        controller.dispose();
      },
    );
  }
}
