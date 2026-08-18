import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/themes/app_colors.dart';
import 'package:flowday/themes/app_spacing.dart';
import 'package:flowday/widgets/task_card_widget.dart';
import 'package:flutter/material.dart';

class AllTasksView extends StatelessWidget {
  final TaskController controller;

  const AllTasksView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todas as tarefas')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (_, _) {
          final tasks = controller.tasks;
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

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            itemCount: tasks.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (_, index) => TaskCardWidget(
              controller: controller,
              task: tasks[index],
            ),
          );
        },
      ),
    );
  }
}
