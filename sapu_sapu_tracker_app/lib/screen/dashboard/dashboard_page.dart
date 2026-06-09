import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sapu_sapu_tracker_app/screen/home/home_page.dart';
import 'package:sapu_sapu_tracker_app/screen/map/map_page.dart';
import 'package:sapu_sapu_tracker_app/screen/statistik/statistik_page.dart';
import 'package:sapu_sapu_tracker_app/screen/report/create_report_page.dart';
import 'package:sapu_sapu_tracker_app/screen/profile/profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  // List of pages to show depending on the selected index
  final List<Widget> _pages = [
    const HomePage(),
    const MapPage(),
    StatistikPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      body: SafeArea(child: _pages[_selectedIndex]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateReportPage()),
          );
        },
        backgroundColor: const Color(0xFF1D9E75),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      color: Colors.white,
      elevation: 0,
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: Container(
        height: 60,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFE0EDE7), width: 0.74),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(iconPath: 'assets/home.svg', label: 'Home', index: 0),
            _buildNavItem(iconPath: 'assets/peta.svg', label: 'Peta', index: 1),
            const SizedBox(width: 48), // Space for FAB
            _buildNavItem(
              iconPath: 'assets/statistik.svg',
              label: 'Statistik',
              index: 2,
            ),
            _buildNavItem(
              iconPath: 'assets/profile.svg',
              label: 'Profil',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String iconPath,
    required String label,
    required int index,
  }) {
    bool isActive = _selectedIndex == index;
    Color color = isActive ? const Color(0xFF1D9E75) : const Color(0xFFBBBBBB);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
