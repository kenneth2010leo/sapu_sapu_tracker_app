import 'package:flutter/material.dart';
import 'package:sapu_sapu_tracker_app/data/firebase.dart';
import 'package:sapu_sapu_tracker_app/widget/login_form.dart';
import 'package:sapu_sapu_tracker_app/widget/login_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sapu_sapu_tracker_app/screen/dashboard/dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sapu_sapu_tracker_app/data/model/user.dart' as model_user;
import 'package:sapu_sapu_tracker_app/data/service/user_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final PageController pageController = PageController(initialPage: 0);
  int currentPage = 0;
  final int maxPage = 3;
  bool lihatPassword = false;
  bool _isLoadingCheck = true;
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTimeStatus();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan indikator loading kosong sementara SharedPreferences membaca data
    if (_isLoadingCheck) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E4D40),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E4D40),
      body: Stack(
        children: [
          PageView(
            controller: pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            children: [
              const LoginDummyWidget(
                title: "Selamat Datang",
                subtitle: "Aplikasi Pelaporan Spesies Ikan Sapu-Sapu.",
              ),
              const LoginDummyWidget(
                title: "Lacak Lokasi",
                subtitle: "Pantau Persebaran Ikan Sapu-Sapu secara real-time.",
              ),
              // Halaman 2: Cukup panggil LoginFormWidget saja seperti semula
              LoginFormWidget(
                onGoogleLoginPressed: () async {
                  try {
                    final credential = await FireBase().signInWithGoogle();

                    if (credential == null || credential.user == null) {
                      // User canceled
                      return;
                    }

                    if (!context.mounted) return;

                    // Simpan profil user ke Firestore
                    final firebaseUser = credential.user!;
                    await UserService().saveUserProfile(
                      model_user.User(
                        userId: firebaseUser.uid,
                        nama: firebaseUser.displayName ?? 'Pengguna Google',
                        email: firebaseUser.email ?? '',
                      ),
                    );

                    if (!context.mounted) return;

                    // Minta izin lokasi langsung setelah login berhasil
                    LocationPermission permission =
                        await Geolocator.checkPermission();
                    if (permission == LocationPermission.denied) {
                      await Geolocator.requestPermission();
                    }

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Selamat datang, ${firebaseUser.displayName ?? "Pengguna"}!',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF338971),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.all(16),
                        elevation: 6,
                      ),
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardPage(),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Login Gagal: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          // Tampilkan indikator dots
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                maxPage,
                (index) => LoginIndicatorWidget(
                  index: index,
                  currentPage: currentPage,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //untuk pindah bagian
  void nextPage() {
    if (currentPage < maxPage - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _checkFirstTimeStatus() async {
    final prefs = await SharedPreferences.getInstance();

    bool isFirst = prefs.getBool('is_first_time') ?? true;

    if (mounted) {
      setState(() {
        _isFirstTime = isFirst;
        _isLoadingCheck = false; // Berhenti loading
      });
    }

    // Jika ini pertama kali, ubah statusnya menjadi false untuk pembukaan berikutnya
    if (isFirst) {
      await prefs.setBool('is_first_time', false);
    } else {
      // Jika BUKAN pertama kali, langsung lompat ke halaman login (indeks ke-2) tanpa animasi
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pageController.hasClients) {
          pageController.jumpToPage(2);
        }
      });
    }
  }
}
