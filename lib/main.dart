import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/views/home_tasks_view.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final taskController = TaskController();
  await taskController.loadTasks();
  runApp(FlowDayApp(controller: taskController));
}

class FlowDayApp extends StatelessWidget {
  final TaskController controller;
  const FlowDayApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: HomeTasksView(controller: controller),
    );
  }
}
