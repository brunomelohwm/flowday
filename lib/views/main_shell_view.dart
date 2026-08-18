import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/themes/app_background.dart';
import 'package:flowday/views/calendar_view.dart';
import 'package:flowday/views/home_tasks_view.dart';
import 'package:flowday/views/profile_view.dart';
import 'package:flowday/widgets/flow_bottom_bar.dart';
import 'package:flutter/material.dart';

class MainShellView extends StatefulWidget {
  final TaskController taskController;

  const MainShellView({super.key, required this.taskController});

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeTasksView(controller: widget.taskController),
      CalendarView(),
      const ProfileView(),
    ];

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: IndexedStack(index: _currentIndex, children: pages),
        ),
        bottomNavigationBar: FlowBottomBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
        ),
      ),
    );
  }
}
