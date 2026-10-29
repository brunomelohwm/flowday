import 'package:flowday/models/task.dart';
import 'package:flowday/models/task_sync_update.dart';

abstract interface class TaskRepository {
  Stream<TaskSyncUpdate> watchTasks(String userId);

  Future<void> createTask(Task task);

  Future<void> updateTask(Task task);

  Future<void> deleteTask(String userId, String taskId);

  Future<void> deleteAllTasks(String userId);
}
