import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sapu_sapu_tracker_app/data/model/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Simpan data ke tabel 'users'
  Future<void> saveUserProfile(User user) async {
    final docRef = _firestore.collection('users').doc(user.userId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // Jika user sudah ada, pertahankan role yang sudah ada di Firestore
      final existingData = docSnapshot.data() as Map<String, dynamic>;
      final existingRole = existingData['role'] ?? 'user';
      
      final userData = user.toJson();
      userData['role'] = existingRole; // kembalikan role aslinya
      
      await docRef.set(userData, SetOptions(merge: true));
    } else {
      // Jika user baru, simpan semua data (termasuk role default 'user')
      await docRef.set(user.toJson(), SetOptions(merge: true));
    }
  }
}