import 'package:flowday/Utils/build_date_info.dart';
import 'package:flowday/widgets/priority_widget.dart';
import 'package:flutter/material.dart';

import 'package:flowday/Utils/date_formatters.dart';
import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/models/task.dart';
import 'package:flowday/views/create_or_edit_task_view.dart';
import 'package:flowday/widgets/glass_container.dart';

class TaskCardWidget extends StatefulWidget {
  final Task task;
  final TaskController controller;
  const TaskCardWidget({
    super.key,
    required this.task,
    required this.controller,
  });

  @override
  State<TaskCardWidget> createState() => _TaskCardWidgetState();
}

class _TaskCardWidgetState extends State<TaskCardWidget> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreateOrEditTaskView(
              controller: widget.controller,
              task: widget.task,
            ),
          ),
        );
      },
      onLongPress: () {
        showDialog(
          context: context,
            builder: (_) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              "Excluir Tarefa?",
              style: TextStyle(color: Color(0xFF212121)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar", style: TextStyle(color: Color(0xFF757575))),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.controller.removeTask(widget.task.id);
                  Navigator.pop(context);
                },
                child: const Text("Excluir"),
              ),
            ],
          ),
        );
      },

      child: GlassContainer(
        child: SizedBox(
          height: 150,
          child: Column(
            mainAxisAlignment: .spaceBetween,
            crossAxisAlignment: .start,

            children: [
              widget.task.priority.widget,
              Text(
                widget.task.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xFF212121),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Color(0xFF757575), size: 18),
                  const SizedBox(width: 4),
                  buildDateInfo(widget.task),
                ],
              ),
              if (widget.task.endDate != null)
                Text(
                  "Due Date: ${formatMonthDay(widget.task.endDate!)}",
                  style: const TextStyle(color: Color(0xFF757575), fontSize: 12),
                ),
              Text(
                'Descrição...',
                style: const TextStyle(color: Color(0xFF757575), fontSize: 14),
                overflow: expanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
