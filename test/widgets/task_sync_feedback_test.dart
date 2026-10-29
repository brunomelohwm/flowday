import 'dart:async';

import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/models/task.dart';
import 'package:flowday/models/task_sync_update.dart';
import 'package:flowday/repositories/task_repository.dart';
import 'package:flowday/widgets/task_sync_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSyncFeedbackRepository extends Mock implements TaskRepository {}

void main() {
  late MockSyncFeedbackRepository repository;
  late StreamController<TaskSyncUpdate> taskEvents;

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

  setUp(() {
    repository = MockSyncFeedbackRepository();
    taskEvents = StreamController<TaskSyncUpdate>.broadcast();
    when(
      () => repository.watchTasks('user-1'),
    ).thenAnswer((_) => taskEvents.stream);
  });

  tearDown(() async {
    await taskEvents.close();
  });

  testWidgets('shows and clears the pending synchronization notice', (
    tester,
  ) async {
    final controller = TaskController(repository: repository);
    controller.setUserId('user-1');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TaskSyncFeedback(controller: controller)),
      ),
    );

    taskEvents.add(TaskSyncUpdate(tasks: const [], hasPendingWrites: true));
    await tester.pump();
    expect(find.text('Aguardando sincronização'), findsOneWidget);

    taskEvents.add(TaskSyncUpdate(tasks: const [], hasPendingWrites: false));
    await tester.pump();
    await tester.pump();
    expect(controller.isSyncPending, isFalse);
    expect(find.text('Aguardando sincronização'), findsNothing);
    controller.dispose();
  });

  testWidgets('shows and dismisses a delayed server write error', (
    tester,
  ) async {
    final write = Completer<void>();
    when(() => repository.createTask(any())).thenAnswer((_) => write.future);
    final controller = TaskController(repository: repository);
    controller.setUserId('user-1');
    taskEvents.add(TaskSyncUpdate(tasks: const [], hasPendingWrites: false));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TaskSyncFeedback(controller: controller)),
      ),
    );
    await tester.pump();

    await controller.addTask(
      const Task(
        id: 'task-1',
        userId: 'user-1',
        title: 'Offline task',
        description: '',
        priority: Priority.medium,
      ),
    );
    write.completeError(StateError('permission denied'));
    await tester.pump();

    expect(
      find.textContaining('Uma alteração não foi sincronizada.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Entendi'));
    await tester.pump();
    expect(
      find.textContaining('Uma alteração não foi sincronizada.'),
      findsNothing,
    );
    controller.dispose();
  });
}
