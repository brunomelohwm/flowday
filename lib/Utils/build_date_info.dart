import 'package:flowday/Utils/date_formatters.dart';
import 'package:flowday/models/task.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flowday/themes/app_colors.dart';

Widget buildDateInfo(Task task) {
  final start = task.startDate;
  final end = task.endDate;

  if (start == null && end == null) {
    return const SizedBox.shrink();
  }

  if (start != null && end != null) {
    return Text(
      "${formatMonthDay(start)} - ${formatMonthDay(end)}",
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
    );
  }

  return Text(
    formatMonthDay(start ?? end!),
    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
  );
}

Map<DateTime, List<Task>> groupTasksByCalendarDay(Iterable<Task> tasks) {
  final grouped = <DateTime, List<Task>>{};

  void addTaskOnDay(Task task, DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    grouped.putIfAbsent(day, () => []).add(task);
  }

  for (final task in tasks) {
    final start = task.startDate;
    final end = task.endDate;
    if (start != null && end != null) {
      final lastDay = DateTime(end.year, end.month, end.day);
      var day = DateTime(start.year, start.month, start.day);
      while (!day.isAfter(lastDay)) {
        addTaskOnDay(task, day);
        day = DateTime(day.year, day.month, day.day + 1);
      }
    } else if (start != null) {
      addTaskOnDay(task, start);
    } else if (end != null) {
      addTaskOnDay(task, end);
    }
  }

  return grouped;
}
