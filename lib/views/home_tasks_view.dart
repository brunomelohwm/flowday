import 'package:flowday/controllers/auth_controller.dart';
import 'package:flowday/models/task.dart';
import 'package:flowday/Utils/build_date_info.dart';
import 'package:flowday/widgets/task_card_widget.dart';
import 'package:flowday/widgets/task_load_feedback.dart';
import 'package:flowday/views/all_tasks_view.dart';
import 'package:flowday/views/completed_tasks_view.dart';
import 'package:flowday/views/create_or_edit_task_view.dart';
import 'package:flowday/themes/app_colors.dart';
import 'package:flowday/themes/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flowday/controllers/task_controller.dart';
import 'package:provider/provider.dart';

class HomeTasksView extends StatelessWidget {
  final TaskController controller;

  const HomeTasksView({super.key, required this.controller});

  String _contextualMessage(List<Task> tasks) {
    final today = DateUtils.dateOnly(DateTime.now());
    final tasksForToday = groupTasksByCalendarDay(tasks)[today]?.length ?? 0;

    if (tasksForToday > 0) {
      final label = tasksForToday == 1 ? 'tarefa' : 'tarefas';
      return '$tasksForToday $label para hoje';
    }

    if (tasks.isEmpty) {
      return 'Tudo em dia';
    }

    final label = tasks.length == 1 ? 'tarefa no total' : 'tarefas no total';
    return '${tasks.length} $label';
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Olá, ${authController.user?.name ?? 'Usuário'}",
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          AnimatedBuilder(
            animation: controller,
            builder: (_, _) => Text(
              _contextualMessage(controller.openTasks),
              style: const TextStyle(
                fontSize: 20,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 44,
            child: FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateOrEditTaskView(controller: controller),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Nova tarefa'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Suas tarefas',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CompletedTasksView(controller: controller),
                  ),
                ),
                child: const Text('Concluídas'),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AllTasksView(controller: controller),
                  ),
                ),
                child: const Text('Ver todos'),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          Expanded(
            child: AnimatedBuilder(
              animation: controller,
              builder: (_, _) {
                final tasks = controller.openTasks;
                if (tasks.isEmpty && controller.isLoading) {
                  return TaskLoadFeedback(
                    isLoading: true,
                    errorMessage: null,
                    onRetry: () {},
                  );
                }
                if (controller.errorMessage != null) {
                  return TaskLoadFeedback(
                    isLoading: false,
                    errorMessage: controller.errorMessage,
                    onRetry: controller.retryLoad,
                  );
                }
                if (tasks.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 44,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Nenhuma tarefa por aqui ainda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Toque no botão + para criar sua primeira tarefa.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final recentTasks = tasks.take(3).toList();
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  itemCount: recentTasks.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, index) {
                    return TaskCardWidget(
                      controller: controller,
                      task: recentTasks[index],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
