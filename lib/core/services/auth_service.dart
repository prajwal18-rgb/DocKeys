import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign Up
  Future<User?> signUp(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  // Login
  Future<User?> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Current User
  User? get currentUser => _auth.currentUser;

  // Email Verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Auth State Changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Reload user (e.g. after email verification)
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }
}
