import 'dart:async';

import 'package:flowday/models/user.dart';
import 'package:flowday/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  AuthController({required AuthRepository repository})
    : _repository = repository {
    _currentUserId = _repository.currentUserId;
    if (_currentUserId != null) {
      _isLoading = true;
      unawaited(_loadProfile(_currentUserId!));
    }
    _authStateSubscription = _repository.authStateChanges().listen(
      (userId) => unawaited(_handleAuthStateChange(userId)),
      onError: _handleAuthStateError,
    );
  }

  final AuthRepository _repository;
  StreamSubscription<String?>? _authStateSubscription;
  String? _currentUserId;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  User? get user => _user;
  String? get currentUserId => _currentUserId;
  bool get isAuthenticated => _currentUserId != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    _notifyIfActive();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String lastName,
  }) => _runAuthAction(() async {
    await _repository.register(
      email: email,
      password: password,
      name: name,
      lastName: lastName,
    );
    final userId = _repository.currentUserId;
    if (userId == null) throw StateError('Cadastro não retornou um usuário.');
    _currentUserId = userId;
    _user = await _repository.loadProfile(userId);
  });

  Future<bool> login({required String email, required String password}) =>
      _runAuthAction(() async {
        await _repository.signIn(email: email, password: password);
        final userId = _repository.currentUserId;
        if (userId == null) throw StateError('Login não retornou um usuário.');
        _currentUserId = userId;
        _user = await _repository.loadProfile(userId);
      });

  Future<bool> sendPasswordResetEmail(String email) =>
      _runAuthAction(() => _repository.sendPasswordResetEmail(email));

  Future<void> retryLoadProfile() async {
    final userId = _currentUserId;
    if (userId == null) return;
    _isLoading = true;
    _errorMessage = null;
    _notifyIfActive();
    await _loadProfile(userId);
  }

  Future<bool> deleteAccount({required String password}) =>
      _runAuthAction(() async {
        await _repository.deleteAccount(password: password);
        _currentUserId = null;
        _user = null;
      });

  Future<bool> logout() async {
    _isLoading = true;
    _errorMessage = null;
    _notifyIfActive();
    try {
      await _repository.signOut();
      _currentUserId = null;
      _user = null;
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      _notifyIfActive();
    }
  }

  Future<bool> _runAuthAction(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    _notifyIfActive();
    try {
      await action();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      _notifyIfActive();
    }
  }

  Future<void> _handleAuthStateChange(String? userId) async {
    if (_disposed) return;
    _currentUserId = userId;
    _user = null;
    if (userId == null) {
      _isLoading = false;
      _notifyIfActive();
      return;
    }
    _isLoading = true;
    _notifyIfActive();
    await _loadProfile(userId);
  }

  Future<void> _loadProfile(String userId) async {
    try {
      final profile = await _repository.loadProfile(userId);
      if (_currentUserId == userId) _user = profile;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      if (_currentUserId == userId) _isLoading = false;
      _notifyIfActive();
    }
  }

  void _handleAuthStateError(Object error, StackTrace stackTrace) {
    _errorMessage = error.toString();
    _isLoading = false;
    _notifyIfActive();
  }

  void _notifyIfActive() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_authStateSubscription?.cancel());
    super.dispose();
  }
}
