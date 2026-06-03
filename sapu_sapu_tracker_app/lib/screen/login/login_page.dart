import 'package:flutter/material.dart';
import 'package:sapu_sapu_tracker_app/data/firebase.dart';
import 'package:sapu_sapu_tracker_app/screen/login/signup_page.dart';
import 'package:sapu_sapu_tracker_app/widget/login_form.dart';
import 'package:sapu_sapu_tracker_app/widget/login_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
            physics: _isFirstTime
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            children: [
              const LoginDummyWidget(
                title: "Selamat Datang",
                subtitle: "Aplikasi pelacak kebersihan Sapu-Sapu.",
              ),
              const LoginDummyWidget(
                title: "Lacak Lokasi",
                subtitle: "Pantau area kerja tim Sapu-Sapu secara real-time.",
              ),
              // Halaman 2: Cukup panggil LoginFormWidget saja seperti semula
              LoginFormWidget(
                onLoginPressed: (emailInput, passwordInput) async {
                  if (emailInput.isEmpty || passwordInput.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Email dan kata sandi tidak boleh kosong!',
                        ),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  try {
                    await FireBase().signInWithEmailAndPassword(
                      email: emailInput,
                      password: passwordInput,
                    );

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Login Berhasil! Selamat datang.'),
                        backgroundColor: Colors.green,
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
          // Tampilkan indikator dots HANYA jika aplikasi dibuka pertama kali
          if (_isFirstTime)
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
