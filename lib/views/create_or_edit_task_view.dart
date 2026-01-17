import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/models/task.dart';
import 'package:flowday/themes/app_background.dart';
import 'package:flowday/widgets/date_field.dart';
import 'package:flowday/widgets/priority_widget.dart';
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
          foregroundColor: const Color(0xFF212121),
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
                        SizedBox(
                          width: 120,
                          height: 30,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Priority>(
                                isExpanded: true,
                                isDense: true,
                                dropdownColor: Colors.white,
                                value: selectedPriority == Priority.none
                                    ? null
                                    : selectedPriority,
                                hint: const Text(
                                  'Prioridade',
                                  style: TextStyle(
                                    color: Color(0xFF757575),
                                    fontSize: 14,
                                  ),
                                ),
                                iconSize: 20,
                                style: const TextStyle(
                                  color: Color(0xFF212121),
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

                        SizedBox(width: 8),

                        SizedBox(
                          width: 100,
                          height: 30,
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
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFF212121),
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                        onSurface: Color(0xFF212121),
                                      ),
                                      dialogTheme: const DialogThemeData(
                                        backgroundColor: Colors.white,
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
                        SizedBox(width: 8),

                        SizedBox(
                          width: 100,
                          height: 30,
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
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFF212121),
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                        onSurface: Color(0xFF212121),
                                      ),
                                      dialogTheme: const DialogThemeData(
                                        backgroundColor: Colors.white,
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
                      style: const TextStyle(color: Color(0xFF212121)),
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Titulo..."),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      style: const TextStyle(color: Color(0xFF212121)),
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
          backgroundColor: const Color(0xFF212121),
          child: const Icon(Icons.check, color: Colors.white),
          onPressed: () {
            final title = titleController.text.trim();
            final description = descriptionController.text.trim();
            final newTask = Task(
              id: widget.task?.id ?? '',
              title: title,
              description: description,
              createdAt: widget.task?.createdAt ?? DateTime.now(),
              updatedAt: DateTime.now(),
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
            if (widget.task == null) {
              widget.controller.addTask(newTask);
            } else {
              widget.controller.updateTask(newTask);
            }
            Navigator.pop(context);
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
