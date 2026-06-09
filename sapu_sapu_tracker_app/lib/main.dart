import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sapu_sapu_tracker_app/screen/login/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // inisialisasi firebase
  await Firebase.initializeApp();

  // Load environment variables dari file .env
  await dotenv.load(fileName: ".env");

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Agar bilah navigasi Android (bawah) transparan dan menyatu dengan warna aplikasi
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );

  // Menyembunyikan jam, baterai, wifi di atas, serta bilah putih di bawah secara total (Immersive Mode)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sapu Sapu Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D9E75)),
        fontFamily: 'Inter', // Default fallback, bisa disesuaikan
      ),
      home: const LoginPage(),
    );
  }
}
