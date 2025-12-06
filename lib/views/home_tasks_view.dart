import 'package:flowday/themes/app_background.dart';
import 'package:flowday/themes/app_colors.dart';
import 'package:flowday/views/create_or_edit_task_view.dart';
import 'package:flowday/widgets/task_card_widget.dart';
import 'package:flutter/material.dart';

import 'package:flowday/controllers/task_controller.dart';

class HomeTasksView extends StatelessWidget {
  final TaskController controller;

  const HomeTasksView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          foregroundColor: Colors.white,
          title: Text(
            "Tarefas",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.95)),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CreateOrEditTaskView(controller: controller),
                  ),
                );
              },
              icon: Icon(
                Icons.add,
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: AppGradients.background),
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final tasks = controller.tasks;

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),

                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];

                  return TaskCardWidget(controller: controller, task: task);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
