import 'package:flowday/models/task.dart';
import 'package:flutter/material.dart';

extension PriorityWidget on Priority {
  Widget get widget {
    switch (this) {
      case Priority.none:
        return _badge(Colors.grey, 'Nenhuma');
      case Priority.low:
        return _badge(Colors.green, 'Baixa');
      case Priority.medium:
        return _badge(Colors.yellow, 'Média');
      case Priority.high:
        return _badge(Colors.red, 'Alta');
    }
  }

  Widget _badge(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}
