import 'dart:async';

import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/models/task.dart';
import 'package:flowday/repositories/task_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockTaskRepository repository;
  late StreamController<List<Task>> taskEvents;

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
    repository = MockTaskRepository();
    taskEvents = StreamController<List<Task>>.broadcast();
    when(
      () => repository.watchTasks('user-1'),
    ).thenAnswer((_) => taskEvents.stream);
    when(() => repository.createTask(any())).thenAnswer((_) async {});
    when(() => repository.updateTask(any())).thenAnswer((_) async {});
    when(() => repository.deleteTask(any(), any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await taskEvents.close();
  });

  test('streams current user tasks and routes CRUD to repository', () async {
    const streamedTask = Task(
      id: 'task-1',
      userId: 'user-1',
      title: 'Review portfolio',
      description: '',
      priority: Priority.high,
    );
    const updatedTask = Task(
      id: 'task-1',
      userId: 'user-1',
      title: 'Review portfolio',
      description: '',
      priority: Priority.high,
      status: TaskStatus.done,
    );

    final controller = TaskController(repository: repository);
    controller.setUserId('user-1');
    taskEvents.add(const [streamedTask]);
    await Future<void>.delayed(Duration.zero);

    expect(controller.tasks, [streamedTask]);

    await controller.addTask(streamedTask);
    final created =
        verify(() => repository.createTask(captureAny())).captured.single
            as Task;
    expect(created.userId, 'user-1');
    expect(created.title, 'Review portfolio');
    expect(created.id, isNot('task-1'));

    await controller.updateTask(updatedTask);
    expect(controller.tasks, [streamedTask]);
    final updated =
        verify(() => repository.updateTask(captureAny())).captured.single
            as Task;
    expect(updated.status, TaskStatus.done);

    await controller.removeTask('task-1');
    verify(() => repository.deleteTask('user-1', 'task-1')).called(1);

    controller.dispose();
  });

  test('separates open and completed tasks while retaining all for calendar', () async {
    final todoTask = Task(
      id: 'todo',
      userId: 'user-1',
      title: 'Todo',
      description: '',
      priority: Priority.none,
      endDate: DateTime(2026, 11, 3),
    );
    final inProgressTask = Task(
      id: 'in-progress',
      userId: 'user-1',
      title: 'In progress',
      description: '',
      priority: Priority.none,
      status: TaskStatus.inProgress,
      endDate: DateTime(2026, 11, 2),
    );
    const completedTask = Task(
      id: 'completed',
      userId: 'user-1',
      title: 'Completed',
      description: '',
      priority: Priority.none,
      status: TaskStatus.done,
    );

    final controller = TaskController(repository: repository);
    controller.setUserId('user-1');
    taskEvents.add([todoTask, completedTask, inProgressTask]);
    await Future<void>.delayed(Duration.zero);

    expect(controller.openTasks, [inProgressTask, todoTask]);
    expect(controller.completedTasks, [completedTask]);
    expect(controller.tasks, [todoTask, completedTask, inProgressTask]);

    controller.dispose();
  });

  test(
    'setTaskStatus persists a completed status for the current user',
    () async {
      const task = Task(
        id: 'task-2',
        userId: 'user-1',
        title: 'Prepare interview',
        description: '',
        priority: Priority.medium,
      );

      final controller = TaskController(repository: repository);
      controller.setUserId('user-1');
      await controller.setTaskStatus(task, TaskStatus.done);

      final persisted =
          verify(() => repository.updateTask(captureAny())).captured.single
              as Task;
      expect(persisted.id, 'task-2');
      expect(persisted.userId, 'user-1');
      expect(persisted.status, TaskStatus.done);
      controller.dispose();
    },
  );
  test('task write failure clears loading and exposes an error', () async {
    when(
      () => repository.createTask(any()),
    ).thenThrow(StateError('write unavailable'));
    final controller = TaskController(repository: repository);
    controller.setUserId('user-1');

    await expectLater(
      controller.addTask(
        const Task(
          id: 'task-3',
          userId: 'user-1',
          title: 'Retry save',
          description: '',
          priority: Priority.low,
        ),
      ),
      throwsA(isA<StateError>()),
    );

    expect(controller.isLoading, isFalse);
    expect(controller.errorMessage, contains('write unavailable'));
    controller.dispose();
  });

  test('stream failure can be retried and loads recovered tasks', () async {
    final failedEvents = StreamController<List<Task>>.broadcast();
    final recoveredEvents = StreamController<List<Task>>.broadcast();
    var subscriptionCount = 0;
    when(() => repository.watchTasks('user-1')).thenAnswer((_) {
      subscriptionCount++;
      return subscriptionCount == 1
          ? failedEvents.stream
          : recoveredEvents.stream;
    });
    const recoveredTask = Task(
      id: 'recovered',
      userId: 'user-1',
      title: 'Recovered task',
      description: '',
      priority: Priority.medium,
    );
    final controller = TaskController(repository: repository);
    controller.setUserId('user-1');
    failedEvents.addError(StateError('stream unavailable'));
    await Future<void>.delayed(Duration.zero);

    expect(controller.isLoading, isFalse);
    expect(controller.errorMessage, contains('stream unavailable'));

    await controller.retryLoad();
    expect(controller.isLoading, isTrue);
    expect(controller.errorMessage, isNull);
    recoveredEvents.add(const [recoveredTask]);
    await Future<void>.delayed(Duration.zero);

    expect(controller.tasks, [recoveredTask]);
    expect(controller.isLoading, isFalse);
    expect(controller.errorMessage, isNull);
    controller.dispose();
    await failedEvents.close();
    await recoveredEvents.close();
  });
}
