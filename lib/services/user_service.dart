import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class UserService {
  static final _db = FirebaseFirestore.instance;
  static const _adminEmail = 'mightyxo123@gmail.com';

  static Future<void> createOrUpdateUser(User firebaseUser) async {
    final ref = _db.collection('users').doc(firebaseUser.uid);
    final doc = await ref.get();

    if (!doc.exists) {
      final isAdmin = firebaseUser.email == _adminEmail;
      await ref.set({
        'uid': firebaseUser.uid,
        'email': firebaseUser.email ?? '',
        'displayName': firebaseUser.displayName ?? '',
        'photoUrl': firebaseUser.photoURL,
        'role': isAdmin ? 'admin' : 'user',
        'disabled': false,
        'createdAt': Timestamp.now(),
      });
    } else {
      await ref.update({
        'displayName': firebaseUser.displayName ?? '',
        'photoUrl': firebaseUser.photoURL,
      });
    }
  }

  static Stream<String?> watchCurrentUserRole() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data()?['role'] as String?);
  }

  static Stream<List<AppUser>> getAllUsers() {
    return _db
        .collection('users')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => AppUser.fromFirestore(doc)).toList());
  }

  static Future<void> updateUserRole(String uid, String role) async {
    await _db.collection('users').doc(uid).update({'role': role});
  }

  static Future<void> setUserDisabled(String uid, bool disabled) async {
    await _db.collection('users').doc(uid).update({'disabled': disabled});
  }
}
