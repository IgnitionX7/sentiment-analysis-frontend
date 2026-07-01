import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';

class AuthService {
  static User? get currentUser => FirebaseAuth.instance.currentUser;
  static Stream<User?> get authStateChanges =>
      FirebaseAuth.instance.authStateChanges();

  static Future<void> signInWithGoogle() async {
    final provider = GoogleAuthProvider();
    final credential =
        await FirebaseAuth.instance.signInWithPopup(provider);
    if (credential.user != null) {
      await UserService.createOrUpdateUser(credential.user!);
    }
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
