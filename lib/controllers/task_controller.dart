import 'dart:async';

import 'package:flowday/models/task.dart';
import 'package:flowday/repositories/task_repository.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TaskController extends ChangeNotifier {
  TaskController({required TaskRepository repository})
    : _repository = repository;

  final TaskRepository _repository;
  final List<Task> _allTasks = [];
  final Uuid uuid = const Uuid();
  String? _currentUserId;
  StreamSubscription<List<Task>>? _tasksSubscription;
  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  List<Task> get tasks => _currentUserId == null
      ? []
      : _allTasks.where((task) => task.userId == _currentUserId).toList();
  String? get currentUserId => _currentUserId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    _notifyIfActive();
  }

  void setUserId(String? userId) {
    if (_currentUserId == userId && _tasksSubscription != null) return;
    _currentUserId = userId;
    _allTasks.clear();
    _errorMessage = null;
    unawaited(_tasksSubscription?.cancel());
    _tasksSubscription = null;

    if (userId == null) {
      _isLoading = false;
      _notifyIfActive();
      return;
    }

    _isLoading = true;
    final subscribedUserId = userId;
    _tasksSubscription = _repository
        .watchTasks(subscribedUserId)
        .listen(
          (tasks) {
            if (_currentUserId != subscribedUserId) return;
            _allTasks
              ..clear()
              ..addAll(tasks);
            _isLoading = false;
            _errorMessage = null;
            _notifyIfActive();
          },
          onError: (Object error, StackTrace stackTrace) {
            if (_currentUserId != subscribedUserId) return;
            _isLoading = false;
            _errorMessage = error.toString();
            _notifyIfActive();
          },
        );
    _notifyIfActive();
  }

  Future<void> addTask(Task task) async {
    final userId = _currentUserId;
    if (userId == null) return;
    final newTask = task.copyWith(id: uuid.v4(), userId: userId);
    await _repository.createTask(newTask);
  }

  Future<void> updateTask(Task task) async {
    final userId = _currentUserId;
    if (userId == null || task.userId != userId) return;
    await _repository.updateTask(task);
  }

  Future<void> removeTask(String taskId) async {
    final userId = _currentUserId;
    if (userId == null) return;
    await _repository.deleteTask(userId, taskId);
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_tasksSubscription?.cancel());
    super.dispose();
  }

  void _notifyIfActive() {
    if (!_disposed) notifyListeners();
  }
}
