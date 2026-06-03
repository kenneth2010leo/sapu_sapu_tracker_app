import 'package:flutter/material.dart';
import 'package:sapu_sapu_tracker_app/screen/login/signup_page.dart';

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({
    super.key,
    required this.onLoginPressed, // Tetap butuh ini untuk mengirim data ke Firebase di halaman utama
  });

  // Callback yang melempar string email dan password saat tombol ditekan
  final Function(String email, String password) onLoginPressed;

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  // Controller dan State mata password sekarang aman di dalam sini
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _lihatPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgIconColor = const Color(0xFF338971);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo & Judul
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgIconColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.pets, size: 45, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sapu-Sapu Tracker',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            // Input Email
            TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Email',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: bgIconColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Input Password
            TextFormField(
              controller: _passwordController,
              obscureText: !_lihatPassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Kata Sandi',
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _lihatPassword = !_lihatPassword;
                    });
                  },
                  child: Icon(
                    _lihatPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: bgIconColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Login
            ElevatedButton(
              onPressed: () {
                widget.onLoginPressed(
                  _emailController.text.trim(),
                  _passwordController.text.trim(),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: bgIconColor,
              ),
              child: const Text('Masuk', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(
              height: 24,
            ), // Beri jarak antara tombol login dan text signup
            // Bagian Signup (PERBAIKAN SINTAKS DI SINI)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Belum memiliki akun? ',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Daftar Sekarang',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
