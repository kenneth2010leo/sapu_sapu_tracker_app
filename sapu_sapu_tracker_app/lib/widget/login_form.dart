import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({super.key, this.onGoogleLoginPressed});

  final VoidCallback? onGoogleLoginPressed;

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  @override
  void dispose() {
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
            Image.asset(
              'assets/for_app/logo_aplikasi.png',
              width: 120,
              height: 120,
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
            const SizedBox(height: 8),
            Text(
              'Pantau & laporkan spesies invasif di perairan sekitarmu', // Saya asumsikan teks penuh dari 'Pantau & laporkan sp...'
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.65),
                height: 1.6, // line-height: 160%
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: widget.onGoogleLoginPressed,
              icon: SvgPicture.asset(
                'assets/for_app/google.svg',
                width: 24,
                height: 24,
              ),
              label: const Text(
                'Masuk dengan Google',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: bgIconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
