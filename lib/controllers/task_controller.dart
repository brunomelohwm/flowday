import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flowday/models/task.dart';
import 'package:uuid/uuid.dart';

class TaskController extends ChangeNotifier {
  final List<Task> _allTasks = [];
  String? _currentUserId;
  final uuid = Uuid();
  StreamSubscription<QuerySnapshot>? _tasksSubscription;

  List<Task> get tasks {
    if (_currentUserId == null) return [];
    return _allTasks.where((task) => task.userId == _currentUserId).toList();
  }

  void setUserId(String? userId) {
    _currentUserId = userId;

   
    _allTasks.clear();
    _tasksSubscription?.cancel();
    if (_currentUserId != null) {
      _subscribeToTasks();
    }
    notifyListeners();
  }

  void _subscribeToTasks() {
    _tasksSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserId)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _allTasks
            ..clear()
            ..addAll(snapshot.docs.map((doc) => Task.fromMap(doc.data())));
          notifyListeners();
        });
  }

  Future<void> addTask(Task task) async {
    if (_currentUserId == null) return;

    final newTask = task.copyWith(
      id: uuid.v4(),
      userId: _currentUserId!,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserId)
        .collection('tasks')
        .doc(newTask.id)
        .set(newTask.toMap());
  }

  Future<void> updateTask(Task task) async {
    if (_currentUserId == null || task.userId != _currentUserId) return;

    final updatedTask = task.copyWith(updatedAt: DateTime.now());

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserId)
        .collection('tasks')
        .doc(task.id)
        .update(updatedTask.toMap());
  }

  Future<void> removeTask(String taskId) async {
    if (_currentUserId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
