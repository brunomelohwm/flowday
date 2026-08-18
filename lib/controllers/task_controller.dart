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
        .snapshots()
        .listen((snapshot) {
          _allTasks
            ..clear()
            ..addAll(
              snapshot.docs.map(
                (doc) => Task.fromMap(doc.data(), id: doc.id),
              ),
            )
            ..sort((first, second) {
              final firstDate = first.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final secondDate = second.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              return secondDate.compareTo(firstDate);
            });
          notifyListeners();
        });
  }

  Future<void> addTask(Task task) async {
    if (_currentUserId == null) return;

    final newTask = task.copyWith(id: uuid.v4(), userId: _currentUserId!);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserId)
        .collection('tasks')
        .doc(newTask.id)
        .set({
          ...newTask.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> updateTask(Task task) async {
    if (_currentUserId == null || task.userId != _currentUserId) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserId)
        .collection('tasks')
        .doc(task.id)
        .update({
          ...task.toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
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
