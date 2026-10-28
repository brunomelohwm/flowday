import 'package:flowday/models/user.dart';

abstract interface class AuthRepository {
  Stream<String?> authStateChanges();

  String? get currentUserId;

  Future<User?> loadProfile(String uid);

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String lastName,
  });

  Future<void> signIn({required String email, required String password});

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();

  Future<void> deleteAccount({required String password});
}
