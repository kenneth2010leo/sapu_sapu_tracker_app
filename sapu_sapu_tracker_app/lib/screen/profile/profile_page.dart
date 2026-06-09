import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sapu_sapu_tracker_app/data/firebase.dart';
import 'package:sapu_sapu_tracker_app/data/firestore_service.dart';
import 'package:sapu_sapu_tracker_app/screen/login/login_page.dart';
import 'package:sapu_sapu_tracker_app/screen/profile/edit_profile_page.dart';
import 'package:sapu_sapu_tracker_app/screen/profile/report_history_page.dart';
import 'package:sapu_sapu_tracker_app/screen/admin/admin_moderation_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildStatsCard(context),
                  const SizedBox(height: 24),
                  _buildMenuSection(),
                  const SizedBox(height: 32),
                  _buildLogoutButton(context),
                  const SizedBox(height: 100), // padding for bottom nav
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName;
    final photoUrl = user?.photoURL;
    final nameStr = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : 'Pengguna Aplikasi';
    final emailStr = user?.email ?? 'Belum ada email';
    final initial = nameStr.isNotEmpty ? nameStr[0].toUpperCase() : 'U';

    Widget fallbackText = Text(
      initial,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1D9E75),
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 32, bottom: 40, left: 20, right: 20),
      decoration: const BoxDecoration(color: Color(0xFF1D9E75)),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            alignment: Alignment.center,
            child: photoUrl != null
                ? ClipOval(
                    child: Image.network(
                      photoUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          fallbackText,
                    ),
                  )
                : fallbackText,
          ),
          const SizedBox(height: 16),
          Text(
            nameStr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            emailStr,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    return Transform.translate(
      offset: const Offset(0, -32),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirestoreService().getUserReportsStream(userEmail ?? ''),
          builder: (context, snapshot) {
            int totalReports = 0;
            int totalFishes = 0;

            if (snapshot.hasData && userEmail != null) {
              final docs = snapshot.data!.docs;
              totalReports = docs.length;
              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;

                final desc = data['description']?.toString() ?? '';
                final match = RegExp(r'^(\d+)').firstMatch(desc);
                if (match != null) {
                  totalFishes += int.tryParse(match.group(1) ?? '0') ?? 0;
                } else {
                  totalFishes += 1;
                }
              }
            }

            return Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    totalReports.toString(),
                    'Laporan Saya',
                  ),
                ),
                Container(width: 1, height: 40, color: const Color(0xFFE0EDE7)),
                Expanded(
                  child: _buildStatItem(totalFishes.toString(), 'Total Ikan'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1D9E75),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF888888),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        bool isAdmin = false;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          isAdmin = (data?['role'] == 'admin');
        }
        
        // Fallback untuk email admin jika di Firestore belum di set
        if (user.email == 'admin.sapu-sapu-tracker.jet@gmail.com') {
          isAdmin = true;
        }

        return Transform.translate(
          offset: const Offset(0, -16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0EDE7), width: 0.74),
            ),
        child: Column(
          children: [
            if (isAdmin) ...[
              _buildMenuItem(
                icon: Icons.admin_panel_settings,
                label: 'Kelola Laporan (Admin)',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminModerationPage(),
                    ),
                  );
                },
              ),
              const Divider(
                height: 1,
                thickness: 0.74,
                color: Color(0xFFE0EDE7),
              ),
            ],
            _buildMenuItem(
              icon: Icons.person_outline,
              label: 'Edit Profil',
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
                if (result == true) {
                  setState(() {}); // Refresh UI
                }
              },
            ),
            const Divider(height: 1, thickness: 0.74, color: Color(0xFFE0EDE7)),
            _buildMenuItem(
              icon: Icons.history,
              label: 'Riwayat Laporan Saya',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportHistoryPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1D9E75)),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF222222),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFFBBBBBB)),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: InkWell(
        onTap: () => _showLogoutDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE24B4A), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Keluar',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE24B4A),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCEBEB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFE24B4A),
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Konfirmasi Keluar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Apakah Anda yakin ingin keluar dari akun ini? Anda harus login kembali untuk melaporkan temuan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF888888),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFFE0EDE7)),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: Color(0xFF888888),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context); // Close dialog
                        await FireBase().signOut();
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE24B4A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Keluar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
