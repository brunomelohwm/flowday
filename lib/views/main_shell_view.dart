import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/views/create_or_edit_task_view.dart';
import 'package:flowday/views/home_tasks_view.dart';
import 'package:flowday/views/profile_page.dart';
import 'package:flowday/widgets/flow_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainShellView extends StatefulWidget {
  const MainShellView({super.key});

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeTasksView(controller: context.read<TaskController>()),
      Placeholder(), // Calendário depois
      ProfileView(),
    ];
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: FlowBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateOrEditTaskView(
                controller: context.read<TaskController>(),
              ),
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
