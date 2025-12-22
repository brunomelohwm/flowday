import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends ChangeNotifier {
  bool _isAutenticated = false;
  bool _isLoading = true;

  bool get isAuthenticated => _isAutenticated;
  bool get isLoading => _isLoading;

  AuthController() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _isAutenticated = prefs.getBool('isLogged') ?? false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogged', true);

    _isAutenticated = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLogged');
    notifyListeners();
  }
}
