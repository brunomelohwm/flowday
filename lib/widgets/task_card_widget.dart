import 'package:flowday/utils/build_date_info.dart';
import 'package:flowday/utils/date_formatters.dart';
import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/models/task.dart';
import 'package:flowday/views/create_or_edit_task_view.dart';
import 'package:flowday/widgets/glass_container.dart';
import 'package:flowday/widgets/priority_widget.dart';
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

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Excluir tarefa?",
          style: TextStyle(color: Color(0xFF212121)),
        ),
        content: const Text("Essa ação não pode ser desfeita."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Color(0xFF757575)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await widget.controller.removeTask(widget.task.id);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Não foi possível excluir a tarefa."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tarefa excluída com sucesso.")),
    );
  }

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
      onLongPress: _confirmDelete,
      child: GlassContainer(
        child: SizedBox(
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  const Icon(
                    Icons.timer_outlined,
                    color: Color(0xFF757575),
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  buildDateInfo(widget.task),
                ],
              ),
              if (widget.task.endDate != null)
                Text(
                  "Data final: ${formatMonthDay(widget.task.endDate!)}",
                  style: const TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 12,
                  ),
                ),
              Text(
                widget.task.description.isEmpty
                    ? 'Sem descrição'
                    : widget.task.description,
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
