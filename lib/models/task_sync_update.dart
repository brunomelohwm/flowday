import 'package:flowday/models/task.dart';

class TaskSyncUpdate {
  TaskSyncUpdate({
    required Iterable<Task> tasks,
    required this.hasPendingWrites,
  }) : tasks = List.unmodifiable(tasks);

  final List<Task> tasks;
  final bool hasPendingWrites;
}
