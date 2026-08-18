import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flowday/themes/app_colors.dart';

Widget dateFiled({
  required String label,
  required DateTime? date,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: 44,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      alignment: .centerLeft,
      child: Text(
        date == null ? label : DateFormat('dd/MM/yy').format(date),
        style: const TextStyle(color: AppColors.textPrimary),
      ),
    ),
  );
}
