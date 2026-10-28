import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flowday/models/user.dart' as app_model;
import 'package:flowday/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Stream<String?> authStateChanges() =>
      _auth.authStateChanges().map((user) => user?.uid);

  @override
  Future<app_model.User?> loadProfile(String uid) async {
    final document = await _firestore.collection('users').doc(uid).get();
    final data = document.data();
    return data == null ? null : app_model.User.fromMap(data);
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String lastName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user?.uid;
    if (uid == null) throw StateError('Firebase did not return a user ID.');

    await _firestore.collection('users').doc(uid).set({
      'id': uid,
      'email': email,
      'name': name,
      'lastName': lastName,
    });
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> deleteAccount({required String password}) async {
    final firebaseUser = _auth.currentUser;
    final email = firebaseUser?.email;
    final uid = firebaseUser?.uid;
    if (firebaseUser == null || email == null || uid == null) {
      throw StateError('Usuário não autenticado.');
    }

    final credential = firebase_auth.EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await firebaseUser.reauthenticateWithCredential(credential);
    await _deleteUserData(uid);
    await firebaseUser.delete();
  }

  Future<void> _deleteUserData(String uid) async {
    final userReference = _firestore.collection('users').doc(uid);
    final tasks = await userReference.collection('tasks').get();
    WriteBatch batch = _firestore.batch();
    var operationCount = 0;

    for (final task in tasks.docs) {
      batch.delete(task.reference);
      operationCount++;
      if (operationCount == 450) {
        await batch.commit();
        batch = _firestore.batch();
        operationCount = 0;
      }
    }

    if (operationCount > 0) await batch.commit();
    await userReference.delete();
  }
}
