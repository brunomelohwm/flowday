import 'package:flowday/utils/build_date_info.dart';
import 'package:flowday/utils/date_formatters.dart';
import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/models/task.dart';
import 'package:flowday/views/create_or_edit_task_view.dart';
import 'package:flowday/widgets/glass_container.dart';
import 'package:flowday/widgets/priority_widget.dart';
import 'package:flowday/themes/app_colors.dart';
import 'package:flowday/themes/app_spacing.dart';
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
  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          "Excluir tarefa?",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text("Essa ação não pode ser desfeita."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: AppColors.textSecondary),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.task.priority.widget,
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.task.title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 4),
                buildDateInfo(widget.task),
              ],
            ),
            if (widget.task.endDate != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  "Data final: ${formatMonthDay(widget.task.endDate!)}",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.task.description.isEmpty
                  ? 'Sem descrição'
                  : widget.task.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
