import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final PageController pageController = PageController(initialPage: 0);
  int currentPage = 0;
  final int maxPage = 3;
  bool lihatPassword = true;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF006B4D);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            //bagian Atas: 3 slider
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: (int page) {
                  setState(() {
                    currentPage = page;
                  });
                },
                children: [
                  buildDummy(
                    "Informasi Fitur 1",
                    "Pantau kondisi air di sekitar Anda dengan mudah dan cepat.",
                  ), // Halaman 2
                  buildDummy(
                    "Informasi Fitur 2",
                    "Laporkan temuan spesies invasif langsung dari genggaman.",
                  ), // Halaman 3
                  buildLogin(),
                ],
              ),
            ),

            //indikator ganti bagian
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  maxPage,
                  (index) => buildIndicator(index),
                ),
              ),
            ),

            //tombol next dan mulai
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // tombol masuk
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentPage != 2) {
                          Placeholder();
                        } else {
                          nextPage();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: bgColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      //kata di tombol
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentPage == 2
                                ? 'Masuk Ke Akun'
                                : 'Mulai Sekarang',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  //text dibawah tombol
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      GestureDetector(
                        //(masih kosong) -> link daftar akun
                        onTap: () {},
                        //textnya
                        child: const Text(
                          'Daftar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //animasi next page
  Widget buildIndicator(int index) {
    bool isActive = currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      //kalo aktif melebar jadi garis
      width: isActive ? 28.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }

  //form login
  Widget buildLogin() {
    final bgIconColor = const Color(0xFF338971);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //logo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgIconColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.pets, size: 45, color: Colors.white),
            ),
            const SizedBox(height: 20),
            //judul
            const Text(
              'Sapu-Sapu Tracker',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            //text dibawah judul
            const Text(
              'Masuk ke akun Anda untuk\nmelanjutkan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 32),

            //email
            TextFormField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                //icon dikiri
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: bgIconColor),
                ),
                //saat dipilih bordernya ganti
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),

            //password
            TextFormField(
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Kata Sandi',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                //icon dikiri
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                //icon dikanan
                suffixIcon: GestureDetector(
                  //ganti icon
                  onTap: () {
                    setState(() {
                      lihatPassword = !lihatPassword;
                    });
                  },
                  child: Icon(
                    lihatPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: bgIconColor),
                ),
                //saat ditekan bordernya ganti warna
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),

            //lupa Sandi
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                //(masih kosong)
                onPressed: () {},
                child: Text(
                  'Lupa Kata Sandi?',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //dummy sementara untuk page1 dan 2
  Widget buildDummy(String title, String subtitle) {
    final secondaryColor = const Color(0xFF338971);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.pets, size: 45, color: Colors.white),
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

  //untuk pindah bagian
  void nextPage() {
    if (currentPage < maxPage - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
