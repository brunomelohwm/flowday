import 'dart:convert';

import 'package:flowday/models/task.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class TaskController extends ChangeNotifier {
  final List<Task> _allTasks = [];
  String? _currentUserId;
  var uuid = Uuid();

  List<Task> get tasks {
    if (_currentUserId == null) return [];
    return _allTasks.where((task) => task.userId == _currentUserId).toList();
  }

  void setUserId(String? userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  void addTask(Task task) {
    if (_currentUserId == null) return;
    final newTask = task.copyWith(id: uuid.v4(), userId: _currentUserId!);
    _allTasks.add(newTask);
    notifyListeners();
    _saveTasks();
  }

  void updateTask(Task updateTask) {
    if (_currentUserId == null || updateTask.userId != _currentUserId) return;
    final index = _allTasks.indexWhere((task) => task.id == updateTask.id);
    if (index != -1) {
      _allTasks[index] = updateTask;
      notifyListeners();
      _saveTasks();
    }
  }

  void removeTask(String taskId) {
    if (_currentUserId == null) return;
    _allTasks.removeWhere(
      (task) => task.id == taskId && task.userId == _currentUserId,
    );
    notifyListeners();
    _saveTasks();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _allTasks.map((t) => t.toMap()).toList();
    prefs.setString('tasks', jsonEncode(list));
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('tasks');

    if (jsonString != null) {
      final decoded = jsonDecode(jsonString) as List;

      _allTasks
        ..clear()
        ..addAll(
          decoded.map((map) {
            // Handle backward compatibility - if userId is missing, assign to current user
            if (map['userId'] == null && _currentUserId != null) {
              map['userId'] = _currentUserId;
            }
            return Task.fromMap(map);
          }).toList(),
        );
      notifyListeners();
    }
  }
}
