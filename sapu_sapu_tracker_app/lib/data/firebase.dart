import 'package:firebase_auth/firebase_auth.dart';

class FireBase {
  // 1. Instance dari FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 2. Stream untuk memantau status login user (Aktif/Tidak)
  // Ini sangat berguna untuk menentukan halaman awal (Login atau Home)
  Stream<User?> get userStream => _auth.authStateChanges();

  // 3. Getter untuk mengambil data user yang sedang login saat ini
  User? get currentUser => _auth.currentUser;

  // 4. Fungsi untuk SIGN UP (Pendaftaran)
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Melempar kembali error spesifik Firebase agar bisa ditangkap di UI
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Terjadi kesalahan yang tidak diketahui.';
    }
  }

  // 5. Fungsi untuk SIGN IN (Login)
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Terjadi kesalahan yang tidak diketahui.';
    }
  }

  // 6. Fungsi untuk SIGN OUT (Logout)
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Helper untuk menerjemahkan error code Firebase ke bahasa Indonesia yang ramah
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password terlalu lemah, minimal 6 karakter.';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Silakan gunakan email lain atau login.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-not-found':
        return 'Pengguna dengan email ini tidak ditemukan.';
      case 'wrong-password':
        return 'Password yang Anda masukkan salah.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      default:
        return 'Terjadi kesalahan autentikasi: ${e.message}';
    }
  }
}