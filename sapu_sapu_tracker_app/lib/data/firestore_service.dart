import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Nama koleksi di Firestore
  final String collectionName = 'reports';

  /// Menyimpan laporan baru ke Firestore
  Future<void> addReport({
    required double lat,
    required double lng,
    required String province,
    required String city,
    required String district,
    required String fullAddress,
    required String reportedBy,
    required String description,
    required String status,
    List<File>? imageFiles,
  }) async {
    try {
      List<String> imageUrls = [];

      // Jika ada file gambar, upload ke Supabase Storage terlebih dahulu
      if (imageFiles != null && imageFiles.isNotEmpty) {
        // Ganti dengan nama bucket Anda jika berbeda
        const String bucketName = 'foto_bukti_ikan'; 

        for (var file in imageFiles) {
          final fileName = file.path.split('/').last;
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          
          // Path file di Supabase
          final String filePath = '$reportedBy/${timestamp}_$fileName';

          // Upload file ke Supabase Storage
          await Supabase.instance.client.storage
              .from(bucketName)
              .upload(filePath, file);

          // Dapatkan URL public (bisa diakses siapa saja karena public bucket)
          final String downloadUrl = Supabase.instance.client.storage
              .from(bucketName)
              .getPublicUrl(filePath);

          imageUrls.add(downloadUrl);
        }
      }

      await _db.collection(collectionName).add({
        'lat': lat,
        'lng': lng,
        'province': province,
        'city': city,
        'district': district,
        'fullAddress': fullAddress,
        'reportedBy': reportedBy,
        'description': description,
        'status': status,
        'imageUrls': imageUrls,
        'timestamp': FieldValue.serverTimestamp(), // Otomatis catat waktu di server
      });
    } catch (e) {
      throw Exception('Gagal menyimpan laporan: $e');
    }
  }

  /// Mengupdate status laporan (Admin)
  Future<void> updateReportStatus(String docId, String newStatus) async {
    await _db.collection(collectionName).doc(docId).update({'status': newStatus});
  }

  /// Membaca data laporan yang sudah di-approve (Untuk Publik)
  Stream<QuerySnapshot> getApprovedReportsStream() {
    return _db
        .collection(collectionName)
        .where('status', whereIn: ['approved', 'Terkonfirmasi']) // Terkonfirmasi untuk backward compatibility data lama
        // .orderBy('timestamp', descending: true) // Dihapus sementara agar tidak perlu bikin Composite Index di Firebase
        .snapshots();
  }

  /// Membaca data laporan yang masih pending (Untuk Admin)
  Stream<QuerySnapshot> getPendingReportsStream() {
    return _db
        .collection(collectionName)
        .where('status', isEqualTo: 'pending')
        // .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Membaca seluruh data laporan milik user tertentu (Untuk Riwayat)
  Stream<QuerySnapshot> getUserReportsStream(String email) {
    return _db
        .collection(collectionName)
        .where('reportedBy', isEqualTo: email)
        // .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Membaca data laporan approved sekali saja (Future) - misalnya untuk statistik
  Future<QuerySnapshot> getApprovedReportsFuture() {
    return _db
        .collection(collectionName)
        .where('status', whereIn: ['approved', 'Terkonfirmasi'])
        .get();
  }
}
