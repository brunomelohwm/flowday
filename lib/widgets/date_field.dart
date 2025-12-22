import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget dateFiled({
  required String label,
  required DateTime? date,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: .centerLeft,
      child: Text(
        date == null ? label : DateFormat('dd/MM/yy').format(date),
        style: TextStyle(color: Colors.white),
      ),
    ),
  );
}
