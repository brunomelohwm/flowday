import 'package:flowday/models/task.dart';

List<Task> sortTasksByDueDate(Iterable<Task> tasks) {
  final sortedTasks = tasks.toList();
  sortedTasks.sort((first, second) {
    final firstDueDate = first.endDate;
    final secondDueDate = second.endDate;
    if (firstDueDate == null && secondDueDate != null) return 1;
    if (firstDueDate != null && secondDueDate == null) return -1;
    if (firstDueDate != null && secondDueDate != null) {
      final dueDateOrder = firstDueDate.compareTo(secondDueDate);
      if (dueDateOrder != 0) return dueDateOrder;
    }

    final firstCreatedAt = first.createdAt;
    final secondCreatedAt = second.createdAt;
    if (firstCreatedAt == null && secondCreatedAt != null) return 1;
    if (firstCreatedAt != null && secondCreatedAt == null) return -1;
    if (firstCreatedAt != null && secondCreatedAt != null) {
      final createdAtOrder = secondCreatedAt.compareTo(firstCreatedAt);
      if (createdAtOrder != 0) return createdAtOrder;
    }

    return first.id.compareTo(second.id);
  });
  return sortedTasks;
}
