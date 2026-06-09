import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sapu_sapu_tracker_app/data/firestore_service.dart';

class ReportHistoryPage extends StatelessWidget {
  const ReportHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Riwayat Laporan Saya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF1D9E75),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: userEmail == null
          ? const Center(child: Text('Anda belum login'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirestoreService().getUserReportsStream(userEmail),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF1D9E75)));
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Terjadi kesalahan memuat riwayat'));
                }

                final userDocs = snapshot.data?.docs ?? [];

                if (userDocs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada riwayat laporan',
                      style: TextStyle(color: Color(0xFF888888)),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: userDocs.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final doc = userDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    final addressParts = [];
                    if ((data['district'] ?? '').isNotEmpty) addressParts.add(data['district']);
                    if ((data['city'] ?? '').isNotEmpty) addressParts.add(data['city']);
                    final address = addressParts.join(' · ');

                    final timestamp = data['timestamp'] as Timestamp?;
                    String timeStr = '';
                    if (timestamp != null) {
                      final diff = DateTime.now().difference(timestamp.toDate());
                      if (diff.inHours > 24) {
                        timeStr = '${diff.inDays} hari lalu';
                      } else if (diff.inHours > 0) {
                        timeStr = '${diff.inHours} jam lalu';
                      } else if (diff.inMinutes > 0) {
                        timeStr = '${diff.inMinutes} menit lalu';
                      } else {
                        timeStr = 'Baru saja';
                      }
                    }

                    final desc = data['description']?.toString() ?? '';
                    String countText = "x1";
                    final match = RegExp(r'^(\d+)').firstMatch(desc);
                    if (match != null) {
                      countText = "x${match.group(1)}";
                    }

                    final status = data['status'] ?? 'pending';
                    Color statusColor;
                    String statusText;
                    if (status == 'approved' || status == 'Terkonfirmasi') {
                      statusColor = const Color(0xFF1D9E75);
                      statusText = 'Disetujui ✅';
                    } else if (status == 'rejected') {
                      statusColor = const Color(0xFFE24B4A);
                      statusText = 'Ditolak ❌';
                    } else {
                      statusColor = Colors.orange;
                      statusText = 'Menunggu ⏳';
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildReportItem(
                        title: addressParts.isNotEmpty ? addressParts.first : 'Lokasi Tidak Diketahui',
                        subtitle: '${addressParts.length > 1 ? addressParts[1] : ''} ${timeStr.isNotEmpty ? '· $timeStr' : ''}',
                        badgeText: countText,
                        badgeTextColor: const Color(0xFFA32D2D),
                        badgeBgColor: const Color(0xFFFCEBEB),
                        statusText: statusText,
                        statusColor: statusColor,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildReportItem({
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeTextColor,
    required Color badgeBgColor,
    required String statusText,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0EDE7), width: 0.74),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222222),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF888888),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 14, color: Color(0xFF888888)),
              const SizedBox(width: 4),
              const Text('Status: ', style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
              Text(statusText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
            ],
          ),
        ],
      ),
    );
  }
}
