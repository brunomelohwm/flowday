import 'dart:async';

import 'package:flowday/Utils/sort_tasks_by_due_date.dart';
import 'package:flowday/models/task.dart';
import 'package:flowday/models/task_sync_update.dart';
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
  StreamSubscription<TaskSyncUpdate>? _tasksSubscription;
  bool _isLoading = false;
  bool _isSyncPending = false;
  String? _errorMessage;
  String? _writeErrorMessage;
  bool _disposed = false;

  List<Task> get tasks => _currentUserId == null
      ? []
      : _allTasks.where((task) => task.userId == _currentUserId).toList();
  List<Task> get openTasks =>
      sortTasksByDueDate(tasks.where((task) => task.status != TaskStatus.done));
  List<Task> get completedTasks =>
      sortTasksByDueDate(tasks.where((task) => task.status == TaskStatus.done));
  String? get currentUserId => _currentUserId;
  bool get isLoading => _isLoading;
  bool get isSyncPending => _isSyncPending;
  String? get errorMessage => _errorMessage;
  String? get writeErrorMessage => _writeErrorMessage;

  void clearError() {
    _errorMessage = null;
    _notifyIfActive();
  }

  void clearWriteError() {
    _writeErrorMessage = null;
    _notifyIfActive();
  }

  void setUserId(String? userId) {
    if (_currentUserId == userId && _tasksSubscription != null) return;

    _currentUserId = userId;
    _allTasks.clear();
    _errorMessage = null;
    _writeErrorMessage = null;
    _isSyncPending = false;
    unawaited(_tasksSubscription?.cancel());
    _tasksSubscription = null;

    if (userId == null) {
      _isLoading = false;
      _notifyIfActive();
      return;
    }

    _isLoading = true;
    _subscribeToTasks(userId);
    _notifyIfActive();
  }

  Future<void> retryLoad() async {
    final userId = _currentUserId;
    if (userId == null) return;

    final previousSubscription = _tasksSubscription;
    _tasksSubscription = null;
    await previousSubscription?.cancel();

    _errorMessage = null;
    _isLoading = true;
    _notifyIfActive();
    _subscribeToTasks(userId);
  }

  void _subscribeToTasks(String userId) {
    try {
      _tasksSubscription = _repository
          .watchTasks(userId)
          .listen(
            (syncUpdate) {
              if (_currentUserId != userId) return;
              _allTasks
                ..clear()
                ..addAll(syncUpdate.tasks);
              _isSyncPending = syncUpdate.hasPendingWrites;
              _isLoading = false;
              _errorMessage = null;
              _notifyIfActive();
            },
            onError: (Object error, StackTrace stackTrace) {
              if (_currentUserId != userId) return;
              _isLoading = false;
              _errorMessage = error.toString();
              _notifyIfActive();
            },
          );
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      _notifyIfActive();
    }
  }

  Future<void> addTask(Task task) async {
    final userId = _currentUserId;
    if (userId == null) return;
    final newTask = task.copyWith(id: uuid.v4(), userId: userId);
    await _runTaskAction(userId, () => _repository.createTask(newTask));
  }

  Future<void> updateTask(Task task) async {
    final userId = _currentUserId;
    if (userId == null || task.userId != userId) return;
    await _runTaskAction(userId, () => _repository.updateTask(task));
  }

  Future<void> setTaskStatus(Task task, TaskStatus status) =>
      updateTask(task.copyWith(status: status));

  Future<void> removeTask(String taskId) async {
    final userId = _currentUserId;
    if (userId == null) return;
    await _runTaskAction(userId, () => _repository.deleteTask(userId, taskId));
  }

  Future<void> _runTaskAction(
    String userId,
    Future<void> Function() action,
  ) async {
    _writeErrorMessage = null;
    _notifyIfActive();
    try {
      unawaited(
        action().then<void>(
          (_) {},
          onError: (Object error, StackTrace stackTrace) {
            if (_currentUserId != userId) return;
            _writeErrorMessage = error.toString();
            _notifyIfActive();
          },
        ),
      );
    } catch (error) {
      if (_currentUserId == userId) {
        _writeErrorMessage = error.toString();
      }
      _notifyIfActive();
    }
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
