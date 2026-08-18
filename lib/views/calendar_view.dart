import 'package:flutter/material.dart';
import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/widgets/task_card_widget.dart';
import 'package:flowday/models/task.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flowday/themes/app_colors.dart';
import 'package:flowday/themes/app_spacing.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _selectedDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDate() {
    final daysDifference = _selectedDate.difference(DateTime.now()).inDays;
    if (daysDifference >= -15 && daysDifference <= 14) {
      final scrollPosition = (daysDifference + 15) * 68.0;
      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _scrollToSelectedDate();
    }
  }

  Map<DateTime, List<Task>> _groupTasksByDate(List<Task> tasks) {
    final Map<DateTime, List<Task>> grouped = {};

    for (var task in tasks) {
      DateTime? taskDate;
      if (task.startDate != null) {
        taskDate = DateTime(
          task.startDate!.year,
          task.startDate!.month,
          task.startDate!.day,
        );
      } else if (task.endDate != null) {
        taskDate = DateTime(
          task.endDate!.year,
          task.endDate!.month,
          task.endDate!.day,
        );
      }

      if (taskDate != null) {
        final dateKey = DateTime(taskDate.year, taskDate.month, taskDate.day);
        grouped.putIfAbsent(dateKey, () => []).add(task);
      }
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final taskController = Provider.of<TaskController>(context);

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
          Row(
            children: [
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Row(
                  children: [
                    Text(
                      DateFormat('MMMM yyyy', 'pt_BR').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 80,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: 30,
              itemBuilder: (context, index) {
                final dayDate = DateTime.now().add(Duration(days: index - 15));
                final isSelected =
                    dayDate.year == _selectedDate.year &&
                    dayDate.month == _selectedDate.month &&
                    dayDate.day == _selectedDate.day;
                final isToday =
                    dayDate.year == DateTime.now().year &&
                    dayDate.month == DateTime.now().month &&
                    dayDate.day == DateTime.now().day;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = dayDate;
                    });
                    _scrollToSelectedDate();
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isToday
                                ? AppColors.surfaceVariant
                                : Colors.transparent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat(
                            'EEE',
                            'pt_BR',
                          ).format(dayDate).substring(0, 3).toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dayDate.day.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Expanded(
            child: AnimatedBuilder(
              animation: taskController,
              builder: (context, _) {
                final tasks = taskController.tasks;
                final groupedTasks = _groupTasksByDate(tasks);

                final selectedDateKey = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                );
                final tasksForDate = groupedTasks[selectedDateKey] ?? [];

                if (tasksForDate.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.event_available_outlined,
                            size: 44,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhuma tarefa para ${DateFormat('d/MM/yyyy', 'pt_BR').format(_selectedDate)}.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Use o botão + para planejar esse dia.',
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

                return ListView.builder(
                  itemCount: tasksForDate.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: TaskCardWidget(
                        controller: taskController,
                        task: tasksForDate[index],
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
