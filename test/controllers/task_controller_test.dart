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
    when(() => repository.updateTask(updatedTask)).thenAnswer((_) async {});

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
    verify(() => repository.updateTask(updatedTask)).called(1);

    await controller.removeTask('task-1');
    verify(() => repository.deleteTask('user-1', 'task-1')).called(1);

    controller.dispose();
  });
}
