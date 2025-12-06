import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/models/task.dart';
import 'package:flowday/themes/app_background.dart';
import 'package:flowday/themes/app_colors.dart';
import 'package:flutter/material.dart';

class CreateOrEditTaskView extends StatefulWidget {
  final Task? task;
  final TaskController controller;
  const CreateOrEditTaskView({super.key, this.task, required this.controller});

  @override
  State<CreateOrEditTaskView> createState() => _CreateOrEditTaskViewState();
}

class _CreateOrEditTaskViewState extends State<CreateOrEditTaskView> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task?.title ?? '');
    descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            foregroundColor: Colors.white,
            title: Text(
              'Criar/Editar',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.95)),
            ),
            backgroundColor: Colors.transparent,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: "Titulo...",
                        labelStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: descriptionController,
                      maxLines: 10,
                      decoration: InputDecoration(
                        labelText: "Escrever...",
                        labelStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            disabledElevation: 0,
            shape: Border.all(color: Colors.white, width: 3),
            backgroundColor: Colors.transparent,
            child: Icon(Icons.check, color: Colors.white),
            onPressed: () {
              final title = titleController.text.trim();
              final description = descriptionController.text.trim();
              final newTask = Task(
                id: widget.task?.id ?? 'Teste',
                title: title,
                description: description,
              );
              if (widget.task == null) {
                widget.controller.addTask(newTask);
              } else {
                widget.controller.updateTask(newTask);
              }
              Navigator.pop(context);
            },
          ),

          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        ),
      ),
    );
  }
}
