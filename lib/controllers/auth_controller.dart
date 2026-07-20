import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flowday/models/user.dart';
import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  fb_auth.User? _currentUser;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;

  fb_auth.User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthController() {
    _currentUser = _auth.currentUser;

    if (_currentUser != null) {
      _loadUser();
    }
    _auth.authStateChanges().listen((user) async {
      _currentUser = user;
      if (user != null) {
        await _loadUser();
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String lastName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _currentUser = credential.user;

      await _firestore.collection('users').doc(_currentUser!.uid).set({
        'id': _currentUser!.uid,
        'email': email,
        'name': name,
        'lastName': lastName,
      });
    } on fb_auth.FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro inesperado: $e';
    }

    _isLoading = false;
    notifyListeners();
    return _errorMessage == null && _currentUser != null;
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = credential.user;
      await _loadUser();
    } on fb_auth.FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro inesperado: $e';
    }

    _isLoading = false;
    notifyListeners();
    return _errorMessage == null && _currentUser != null;
  }

  Future<void> _loadUser() async {
    if (_currentUser == null) return;

    final doc = await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .get();

    if (doc.exists) {
      _user = User.fromMap(doc.data()!);
    } else {
      _user = null;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on fb_auth.FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro inesperado: $e';
    }

    _isLoading = false;
    notifyListeners();
    return _errorMessage == null;
  }

  Future<bool> deleteAccount({required String password}) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      _errorMessage = 'Usuário não autenticado.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = fb_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      await _deleteUserData(user.uid);
      await user.delete();
      _currentUser = null;
      _user = null;
    } on fb_auth.FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Erro inesperado: $e';
    }

    _isLoading = false;
    notifyListeners();
    return _errorMessage == null;
  }

  Future<void> _deleteUserData(String uid) async {
    final userRef = _firestore.collection('users').doc(uid);

    final tasksSnapshot = await userRef.collection('tasks').get();

    WriteBatch batch = _firestore.batch();
    int opCount = 0;

    for (final doc in tasksSnapshot.docs) {
      batch.delete(doc.reference);
      opCount++;

      if (opCount >= 450) {
        await batch.commit();
        batch = _firestore.batch();
        opCount = 0;
      }
    }

    await batch.commit();

    await userRef.delete();
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    _user = null;
    notifyListeners();
  }
}
