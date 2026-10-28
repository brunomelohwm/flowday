import 'package:flowday/models/task.dart';

abstract interface class TaskRepository {
  Stream<List<Task>> watchTasks(String userId);

  Future<void> createTask(Task task);

  Future<void> updateTask(Task task);

  Future<void> deleteTask(String userId, String taskId);

  Future<void> deleteAllTasks(String userId);
}
