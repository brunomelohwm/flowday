import 'package:flowday/themes/app_background.dart';
import 'package:flowday/themes/app_colors.dart';
import 'package:flowday/widgets/task_card_widget.dart';
import 'package:flutter/material.dart';

import 'package:flowday/controllers/task_controller.dart';

class HomeTasksView extends StatelessWidget {
  final TaskController controller;

  const HomeTasksView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: Scaffold(
          backgroundColor: Colors.transparent,

          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Olá,  ^^",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: 220,
                    child: Text(
                      maxLines: 2,
                      "Gerencie Suas Tarefas Diárias",
                      style: TextStyle(fontSize: 28, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Em Andamento',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        'Ver Todos',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),

                  Expanded(
                    child: AnimatedBuilder(
                      animation: controller,
                      builder: (context, _) {
                        final tasks = controller.tasks;
                        return ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return Container(
                              padding: .only(top: 15),
                              child: TaskCardWidget(
                                controller: controller,
                                task: task,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          //  bottomNavigationBar: FlowBottomBar(),
        ),
      ),
    );
  }
}
