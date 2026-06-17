import 'package:firebase_auth/firebase_auth.dart';

class RoleHelper {
  static const String adminEmail = "admin@dockeys.com";

  static bool get isAdmin {
    final user = FirebaseAuth.instance.currentUser;
    return user != null && user.email == adminEmail;
  }
}
