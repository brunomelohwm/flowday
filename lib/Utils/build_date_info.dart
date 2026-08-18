import 'package:flowday/utils/date_formatters.dart';
import 'package:flowday/models/task.dart';
import 'package:flutter/material.dart';
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
