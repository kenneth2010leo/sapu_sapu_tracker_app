import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sapu_sapu_tracker_app/data/model/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Simpan data ke tabel 'users'
  Future<void> saveUserProfile(User user) async {
    await _firestore
        .collection('users')
        .doc(user.userId)
        .set(user.toJson());
  }
}