import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static User? get currentUser => FirebaseAuth.instance.currentUser;
  static Stream<User?> get authStateChanges =>
      FirebaseAuth.instance.authStateChanges();

  static Future<void> signInWithGoogle() async {
    final provider = GoogleAuthProvider();
    await FirebaseAuth.instance.signInWithPopup(provider);
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
