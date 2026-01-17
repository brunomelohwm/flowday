import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flowday/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AuthController extends ChangeNotifier {
  bool _isAutenticated = false;
  bool _isLoading = true;
  User? _currentUser;
  String? _errorMessage;
  final _uuid = Uuid();

  bool get isAuthenticated => _isAutenticated;
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  AuthController() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('currentUserId');

    if (userId != null) {
      final usersJson = prefs.getString('users');
      if (usersJson != null) {
        final List<dynamic> usersList = jsonDecode(usersJson);
        final userMap = usersList.firstWhere(
          (u) => (u as Map<String, dynamic>)['id'] == userId,
          orElse: () => null,
        );

        if (userMap != null) {
          _currentUser = User.fromMap(userMap as Map<String, dynamic>);
          _isAutenticated = true;
        }
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<String?> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    _errorMessage = null;

    if (email.isEmpty) {
      _errorMessage = 'Email é obrigatório';
      notifyListeners();
      return _errorMessage;
    }

    if (!_isValidEmail(email)) {
      _errorMessage = 'Email inválido';
      notifyListeners();
      return _errorMessage;
    }

    if (password.isEmpty) {
      _errorMessage = 'Senha é obrigatória';
      notifyListeners();
      return _errorMessage;
    }

    if (password.length < 6) {
      _errorMessage = 'Senha deve ter pelo menos 6 caracteres';
      notifyListeners();
      return _errorMessage;
    }

    if (password != confirmPassword) {
      _errorMessage = 'As senhas não coincidem';
      notifyListeners();
      return _errorMessage;
    }

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    List<Map<String, dynamic>> users = [];

    if (usersJson != null) {
      users = (jsonDecode(usersJson) as List)
          .map((u) => u as Map<String, dynamic>)
          .toList();
    }

    if (users.any((u) => u['email'].toLowerCase() == email.toLowerCase())) {
      _errorMessage = 'Email já cadastrado';
      _isLoading = false;
      notifyListeners();
      return _errorMessage;
    }

    final newUser = User(
      id: _uuid.v4(),
      email: email.toLowerCase().trim(),
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now(),
    );

    users.add(newUser.toMap());
    await prefs.setString('users', jsonEncode(users));

    _currentUser = newUser;
    _isAutenticated = true;
    await prefs.setString('currentUserId', newUser.id);

    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
    return null;
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    _errorMessage = null;

    if (email.isEmpty) {
      _errorMessage = 'Email é obrigatório';
      notifyListeners();
      return _errorMessage;
    }

    if (!_isValidEmail(email)) {
      _errorMessage = 'Email inválido';
      notifyListeners();
      return _errorMessage;
    }

    if (password.isEmpty) {
      _errorMessage = 'Senha é obrigatória';
      notifyListeners();
      return _errorMessage;
    }

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');

    if (usersJson == null) {
      _errorMessage = 'Email ou senha incorretos';
      _isLoading = false;
      notifyListeners();
      return _errorMessage;
    }

    final List<dynamic> usersList = jsonDecode(usersJson);
    final userMap = usersList.firstWhere(
      (u) =>
          (u as Map<String, dynamic>)['email'].toLowerCase() ==
          email.toLowerCase().trim(),
      orElse: () => null,
    );

    if (userMap == null) {
      _errorMessage = 'Email ou senha incorretos';
      _isLoading = false;
      notifyListeners();
      return _errorMessage;
    }

    final user = User.fromMap(userMap as Map<String, dynamic>);
    final passwordHash = _hashPassword(password);

    if (user.passwordHash != passwordHash) {
      _errorMessage = 'Email ou senha incorretos';
      _isLoading = false;
      notifyListeners();
      return _errorMessage;
    }

    _currentUser = user;
    _isAutenticated = true;
    await prefs.setString('currentUserId', user.id);

    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUserId');
    _currentUser = null;
    _isAutenticated = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
