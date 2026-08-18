import 'package:flowday/controllers/auth_controller.dart';
import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/models/task.dart';
import 'package:flowday/themes/app_background.dart';
import 'package:flowday/widgets/date_field.dart';
import 'package:flowday/widgets/priority_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flowday/themes/app_colors.dart';

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
  Priority selectedPriority = Priority.none;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task?.title ?? '');
    descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    selectedPriority = widget.task?.priority ?? Priority.none;

    startDate = widget.task?.startDate;
    endDate = widget.task?.endDate;
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
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
          backgroundColor: Colors.transparent,
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 12,
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 44),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.outline,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Priority>(
                                isExpanded: true,
                                isDense: true,
                                dropdownColor: AppColors.surface,
                                value: selectedPriority == Priority.none
                                    ? null
                                    : selectedPriority,
                                hint: const Text(
                                  'Prioridade',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                iconSize: 20,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                ),

                                items: Priority.values.map((p) {
                                  return DropdownMenuItem(
                                    value: p,
                                    child: p.widget,
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedPriority = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          flex: 10,
                          child: dateFiled(
                            label: "Início",
                            date: startDate,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: AppColors.primary,
                                        onPrimary: AppColors.background,
                                        surface: AppColors.surface,
                                        onSurface: AppColors.textPrimary,
                                      ),
                                      dialogTheme: const DialogThemeData(
                                        backgroundColor: AppColors.surface,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (picked != null) {
                                setState(() => startDate = picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),

                        Expanded(
                          flex: 10,
                          child: dateFiled(
                            label: "Fim",
                            date: endDate,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: AppColors.primary,
                                        onPrimary: AppColors.background,
                                        surface: AppColors.surface,
                                        onSurface: AppColors.textPrimary,
                                      ),
                                      dialogTheme: const DialogThemeData(
                                        backgroundColor: AppColors.surface,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (picked != null) {
                                setState(() => endDate = picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      style: const TextStyle(color: AppColors.textPrimary),
                      controller: titleController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: "Título..."),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      style: const TextStyle(color: AppColors.textPrimary),
                      controller: descriptionController,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        alignLabelWithHint: true,
                        labelText: "Descrição...",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          disabledElevation: 0,
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.check, color: AppColors.background),
          onPressed: () async {
            final auth = context.read<AuthController>();
            if (auth.currentUser == null) return;

            final title = titleController.text.trim();
            final description = descriptionController.text.trim();

            if (title.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Informe um título para salvar a tarefa."),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final newTask = Task(
              id: widget.task?.id ?? '',
              userId: auth.currentUser!.uid,
              title: title,
              description: description,
              priority: selectedPriority,
              startDate: startDate,
              endDate: endDate,
            );
            if (startDate != null &&
                endDate != null &&
                endDate!.isBefore(startDate!)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "A data de término não pode ser antes da data de início",
                  ),
                ),
              );
              return;
            }
            try {
              if (widget.task == null) {
                await widget.controller.addTask(newTask);
              } else {
                await widget.controller.updateTask(newTask);
              }
            } catch (_) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Não foi possível salvar a tarefa."),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.task == null
                      ? "Tarefa criada com sucesso."
                      : "Tarefa atualizada com sucesso.",
                ),
              ),
            );
            Navigator.pop(context);
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
