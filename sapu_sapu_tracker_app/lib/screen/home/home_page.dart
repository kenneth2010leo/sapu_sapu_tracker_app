import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sapu_sapu_tracker_app/data/firestore_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirestoreService().getApprovedReportsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Terjadi kesalahan'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];
              
              int totalLaporan = docs.length;
              Set<String> uniqueDistricts = {};
              Set<String> uniqueContributors = {};
              int laporanMingguIni = 0;
              final now = DateTime.now();

              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                
                final district = data['district']?.toString() ?? '';
                if (district.isNotEmpty) uniqueDistricts.add(district);
                
                final reportedBy = data['reportedBy']?.toString() ?? '';
                if (reportedBy.isNotEmpty) uniqueContributors.add(reportedBy);

                final timestamp = data['timestamp'] as Timestamp?;
                if (timestamp != null) {
                  final date = timestamp.toDate();
                  if (now.difference(date).inDays <= 7) {
                    laporanMingguIni++;
                  }
                }
              }

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildStatsGrid(
                      context,
                      totalLaporan: totalLaporan.toString(),
                      lokasiTerpantau: uniqueDistricts.length.toString(),
                      kontributor: uniqueContributors.length.toString(),
                      mingguIni: '$laporanMingguIni Baru',
                    ),
                    const SizedBox(height: 24),
                    _buildReportTitle(),
                    const SizedBox(height: 16),
                    _buildReportList(docs),
                    const SizedBox(height: 100), // padding for bottom nav
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      height: 108.0, // Dari CSS: 107.75px
      padding: const EdgeInsets.only(left: 20, right: 20, top: 52), // Dari CSS: top 51.99px, left 19.99px
      decoration: const BoxDecoration(
        color: Color(0xFF1D9E75),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 9.0), // Menyesuaikan topbar-title top: 9.06px relative to div
            child: Text(
              'Sapu-Sapu Tracker',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400, // CSS font-weight: 400
              ),
            ),
          ),
          const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, {
    required String totalLaporan,
    required String lokasiTerpantau,
    required String kontributor,
    required String mingguIni,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              _buildStatCard(
                context: context,
                iconPath: 'assets/total_laporan.svg',
                iconBgColor: const Color(0xFFE1F5EE),
                value: totalLaporan,
                valueColor: const Color(0xFF0F6E56),
                label: 'Total Laporan',
              ),
              const SizedBox(height: 10),
              _buildStatCard(
                context: context,
                iconPath: 'assets/kontributor.svg',
                iconBgColor: const Color(0xFFE6F1FB),
                value: kontributor,
                valueColor: const Color(0xFF185FA5),
                label: 'Kontributor',
              ),
            ],
          ),
          Column(
            children: [
              _buildStatCard(
                context: context,
                iconPath: 'assets/lokasi_terpantau.svg',
                iconBgColor: const Color(0xFFFAEEDA),
                value: lokasiTerpantau,
                valueColor: const Color(0xFFEF9F27),
                label: 'Lokasi Terpantau',
              ),
              const SizedBox(height: 10),
              _buildStatCard(
                context: context,
                iconPath: 'assets/minggu_ini.svg',
                iconBgColor: const Color(0xFFFCEBEB),
                value: mingguIni,
                valueColor: const Color(0xFFE24B4A),
                label: 'Minggu Ini',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String iconPath,
    required Color iconBgColor,
    required String value,
    required Color valueColor,
    required String label,
  }) {
    // We adjust width to be half of the screen minus some padding
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 21,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0EDE7), width: 0.74),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(iconPath),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Laporan Terbaru',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF222222),
        ),
      ),
    );
  }

  Widget _buildReportList(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Belum ada laporan', style: TextStyle(color: Colors.grey)),
      );
    }

    final topDocs = docs.take(3).toList();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: topDocs.map((doc) {
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
          // Ekstrak angka pertama dari deskripsi e.g. "12 ekor ikan sapu-sapu"
          String countText = "1 Ikan Sapu-Sapu";
          final match = RegExp(r'^(\d+)').firstMatch(desc);
          if (match != null) {
            countText = "${match.group(1)} Ikan Sapu-Sapu";
          }
          
          final List<dynamic> images = data['imageUrls'] ?? [];
          String? imageUrl;
          if (images.isNotEmpty) {
            imageUrl = images.first.toString();
          }

          final String fullAddress = data['fullAddress']?.toString() ?? '';
          final String title = fullAddress.isNotEmpty 
              ? fullAddress 
              : (addressParts.isNotEmpty ? addressParts.first : 'Lokasi Tidak Diketahui');
          
          final String subtitle = fullAddress.isNotEmpty
              ? timeStr
              : '${addressParts.length > 1 ? addressParts[1] : ''} ${timeStr.isNotEmpty ? '· $timeStr' : ''}'.trim();

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildReportItem(
              title: title,
              subtitle: subtitle,
              badgeText: countText,
              badgeTextColor: const Color(0xFFA32D2D), 
              badgeBgColor: const Color(0xFFFCEBEB),
              imageUrl: imageUrl,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReportItem({
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeTextColor,
    required Color badgeBgColor,
    String? imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0EDE7), width: 0.74),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE1F5EE),
              borderRadius: BorderRadius.circular(8),
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: imageUrl == null ? const Text('🐟', style: TextStyle(fontSize: 22)) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 10, color: Color(0xFF888888)),
                    const SizedBox(width: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeBgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: badgeTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
