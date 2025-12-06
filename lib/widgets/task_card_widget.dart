import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/models/task.dart';
import 'package:flowday/views/create_or_edit_task_view.dart';
import 'package:flowday/widgets/glass_container.dart';
import 'package:flutter/material.dart';

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
            title: Text("Excluir Tarefa?"),
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
        child: Column(
          crossAxisAlignment: .start,

          children: [
            Text(
              widget.task.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),

            SizedBox(height: 4),
            Text(
              style: TextStyle(color: Colors.white.withValues(alpha: 0.80)),
              widget.task.description,
              maxLines: 6,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
