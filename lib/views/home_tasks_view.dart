import 'package:flowday/controllers/auth_controller.dart';
import 'package:flowday/widgets/task_card_widget.dart';
import 'package:flutter/material.dart';

import 'package:flowday/controllers/task_controller.dart';
import 'package:provider/provider.dart';

class HomeTasksView extends StatelessWidget {
  final TaskController controller;

  const HomeTasksView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "Olá, ${authController.user?.name ?? 'Usuário'}",
            style: TextStyle(fontSize: 20, color: Color(0xFF212121)),
          ),
          const SizedBox(height: 10),

          const SizedBox(
            width: 220,
            child: Text(
              "Gerencie Suas Tarefas Diárias",
              maxLines: 2,
              style: TextStyle(
                fontSize: 28,
                color: Color(0xFF212121),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Em Andamento',
                style: TextStyle(
                  color: Color(0xFF212121),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
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
                            color: Color(0xFF757575),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Nenhuma tarefa por aqui ainda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF212121),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Toque no botão + para criar sua primeira tarefa.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF757575),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

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
