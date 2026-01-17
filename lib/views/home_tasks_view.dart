import 'package:flowday/widgets/task_card_widget.dart';
import 'package:flutter/material.dart';

import 'package:flowday/controllers/task_controller.dart';

class HomeTasksView extends StatelessWidget {
  final TaskController controller;

  const HomeTasksView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            "Olá, ^^",
            style: TextStyle(fontSize: 20, color: Color(0xFF212121)),
          ),
          const SizedBox(height: 10),

          const SizedBox(
            width: 220,
            child: Text(
              "Gerencie Suas Tarefas Diárias",
              maxLines: 2,
              style: TextStyle(fontSize: 28, color: Color(0xFF212121), fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Em Andamento',
                style: TextStyle(color: Color(0xFF212121), fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Text(
                'Ver Todos',
                style: TextStyle(color: Color(0xFF757575), fontSize: 14),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Expanded(
            child: AnimatedBuilder(
              animation: controller,
              builder: (_, _) {
                final tasks = controller.tasks;
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (_, index) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: TaskCardWidget(
                        controller: controller,
                        task: tasks[index],
                      ),
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
