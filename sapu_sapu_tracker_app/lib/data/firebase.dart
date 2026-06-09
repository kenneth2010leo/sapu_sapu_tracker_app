import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FireBase {
  // 1. Instance dari FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 2. Stream untuk memantau status login user (Aktif/Tidak)
  // Ini sangat berguna untuk menentukan halaman awal (Login atau Home)
  Stream<User?> get userStream => _auth.authStateChanges();

  // 3. Getter untuk mengambil data user yang sedang login saat ini
  User? get currentUser => _auth.currentUser;


  // 6. Fungsi untuk SIGN IN dengan Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Terjadi kesalahan saat login dengan Google: $e';
    }
  }

  // 7. Fungsi untuk SIGN OUT (Logout)
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
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