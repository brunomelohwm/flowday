import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/themes/app_colors.dart';
import 'package:flowday/themes/app_spacing.dart';
import 'package:flowday/widgets/task_card_widget.dart';
import 'package:flowday/widgets/task_load_feedback.dart';
import 'package:flowday/widgets/due_date_sort_button.dart';
import 'package:flowday/Utils/sort_tasks_by_due_date.dart';
import 'package:material_ui/material_ui.dart';

class AllTasksView extends StatefulWidget {
  final TaskController controller;

  const AllTasksView({super.key, required this.controller});

  @override
  State<AllTasksView> createState() => _AllTasksViewState();
}

class _AllTasksViewState extends State<AllTasksView> {
  bool _descending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tarefas em aberto')),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (_, _) {
          final tasks = sortTasksByDueDate(
            widget.controller.openTasks,
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
                  'Você ainda não criou nenhuma tarefa.',
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
}
