import 'package:flowday/Utils/sort_tasks_by_due_date.dart';
import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/themes/app_colors.dart';
import 'package:flowday/themes/app_spacing.dart';
import 'package:flowday/widgets/due_date_sort_button.dart';
import 'package:flowday/widgets/task_card_widget.dart';
import 'package:flowday/widgets/task_load_feedback.dart';
import 'package:flutter/material.dart';

class CompletedTasksView extends StatefulWidget {
  const CompletedTasksView({super.key, required this.controller});

  final TaskController controller;

  @override
  State<CompletedTasksView> createState() => _CompletedTasksViewState();
}

class _CompletedTasksViewState extends State<CompletedTasksView> {
  bool _descending = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tarefas concluídas')),
    body: AnimatedBuilder(
      animation: widget.controller,
      builder: (_, _) {
        final tasks = sortTasksByDueDate(
          widget.controller.completedTasks,
          descending: _descending,
        );
        if (tasks.isEmpty && widget.controller.isLoading) {
          return TaskLoadFeedback(
            isLoading: true,
            errorMessage: null,
            onRetry: widget.controller.retryLoad,
          );
        }
        if (widget.controller.errorMessage != null) {
          return TaskLoadFeedback(
            isLoading: false,
            errorMessage: widget.controller.errorMessage,
            onRetry: widget.controller.retryLoad,
          );
        }
        if (tasks.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Nenhuma tarefa concluída.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        return Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: DueDateSortButton(
                descending: _descending,
                onPressed: () => setState(() => _descending = !_descending),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                itemCount: tasks.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, index) => TaskCardWidget(
                  controller: widget.controller,
                  task: tasks[index],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
