import 'package:flutter/material.dart';

// ==========================================
// 1. COMPONENT INDICATOR (STATELESS)
// ==========================================
class LoginIndicatorWidget extends StatelessWidget {
  const LoginIndicatorWidget({
    super.key,
    required this.index,
    required this.currentPage,
  });

  final int index;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    bool isActive = currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 28.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}

// ==========================================
// 2. COMPONENT DUMMY INTRO PAGE (STATELESS)
// ==========================================
class LoginDummyWidget extends StatelessWidget {
  const LoginDummyWidget({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final secondaryColor = const Color(0xFF338971);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo_aplikasi.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}