import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // Existing accounts receive the same least-privileged profile as new accounts.
  // Never overwrite an existing role on login or signup.
  Future<void> ensureProfile(User user) async {
    final ref = _firestore.collection('users').doc(user.uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        transaction.set(ref, {
          'email': user.email ?? '',
          'role': UserRole.user.name,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }).timeout(const Duration(seconds: 20));
  }

  Stream<AppUser?> watchProfile(String uid) => _firestore
          .collection('users')
          .doc(uid)
          .snapshots(includeMetadataChanges: true)
          .map((snapshot) {
        // Cached or optimistic local writes must not grant privileged UI access.
        if (snapshot.metadata.isFromCache ||
            snapshot.metadata.hasPendingWrites) {
          return null;
        }
        final data = snapshot.data();
        if (data == null) throw StateError('Không tìm thấy hồ sơ tài khoản.');
        return AppUser.fromMap(uid, data);
      });

  Stream<List<AppUser>> watchUsers() => _firestore
      .collection('users')
      .orderBy('email')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => AppUser.fromMap(doc.id, doc.data()))
          .toList());

  Future<void> changeRole(String uid, UserRole role) => _firestore
      .collection('users')
      .doc(uid)
      .update({'role': role.name, 'updatedAt': FieldValue.serverTimestamp()});
}
