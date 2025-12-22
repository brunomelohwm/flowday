// ignore_for_file: public_member_api_docs, sort_constructors_first
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
            backgroundColor: Colors.transparent,
            title: Text(
              "Excluir Tarefa?",
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.controller.removeTask(widget.task.id);
                  Navigator.pop(context);
                },
                child: Text("Ecluir"),
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.timer_outlined, color: Colors.white),
                  buildDateInfo(widget.task),
                ],
              ),
              if (widget.task.endDate != null)
                Text(
                  "Due Date: ${formatMonthDay(widget.task.endDate!)}",
                  style: TextStyle(color: Colors.white),
                ),
              Text(
                style: TextStyle(color: Colors.white.withValues(alpha: 0.80)),

                'Descrição...',

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
