import 'package:flutter/material.dart';
import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/widgets/task_card_widget.dart';
import 'package:flowday/models/task.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
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
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Color(0xFF757575),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF212121)
                          : (isToday
                                ? const Color(0xFFE0E0E0)
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
                                : const Color(0xFF757575),
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
                                : const Color(0xFF212121),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

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
                    child: Text(
                      'Nenhuma tarefa para ${DateFormat('d/MM/yyyy', 'pt_BR').format(_selectedDate)}',
                      style: const TextStyle(
                        color: Color(0xFF757575),
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: tasksForDate.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
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
