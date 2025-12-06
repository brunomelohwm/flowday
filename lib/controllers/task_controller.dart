import 'dart:convert';

import 'package:flowday/models/task.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class TaskController extends ChangeNotifier {
  final List<Task> _tasks = [];
  var uuid = Uuid();

  List<Task> get tasks => _tasks;

  void addTask(Task task) {
    final newTask = task.copyWith(id: uuid.v4());
    _tasks.add(newTask);
    notifyListeners();
    _saveTasks();
  }

  void updateTask(Task updateTask) {
    final index = _tasks.indexWhere((task) => task.id == updateTask.id);
    if (index != -1) {
      _tasks[index] = updateTask;
      notifyListeners();
      _saveTasks();
    }
  }

  void removeTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
    _saveTasks();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = tasks.map((t) => t.toMap()).toList();
    prefs.setString('tasks', jsonEncode(list));
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('tasks');

    if (jsonString != null) {
      final decoded = jsonDecode(jsonString) as List;

      _tasks
        ..clear()
        ..addAll(decoded.map((map) => Task.fromMap(map)).toList());
      notifyListeners();
    }
  }
}
