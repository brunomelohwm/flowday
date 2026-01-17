import 'package:flowday/Utils/date_formatters.dart';
import 'package:flowday/models/task.dart';
import 'package:flutter/material.dart';

Widget buildDateInfo(Task task) {
  final start = task.startDate;
  final end = task.endDate;

  if (start == null && end == null) {
    return const SizedBox.shrink();
  }

  if (start != null && end != null) {
    return Text(
      "${formatMonthDay(start)} - ${formatMonthDay(end)}",
      style: const TextStyle(color: Color(0xFF757575), fontSize: 12),
    );
  }

  return Text(
    formatMonthDay(start ?? end!),
    style: const TextStyle(color: Color(0xFF757575), fontSize: 12),
  );
}
