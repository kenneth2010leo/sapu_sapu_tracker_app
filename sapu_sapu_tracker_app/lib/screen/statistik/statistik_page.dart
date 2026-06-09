import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sapu_sapu_tracker_app/data/firestore_service.dart';

class StatistikPage extends StatelessWidget {
  StatistikPage({super.key});

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getApprovedReportsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF1D9E75)));
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Gagal memuat data statistik'));
              }
              
              final docs = snapshot.data?.docs ?? [];

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    _buildDonutChartCard(docs, 'province', 'Distribusi per Provinsi'),
                    const SizedBox(height: 16),
                    _buildDonutChartCard(docs, 'city', 'Distribusi per Kota/Kabupaten'),
                    const SizedBox(height: 16),
                    _buildRankCard(docs),
                    const SizedBox(height: 100), // padding for bottom nav
                  ],
                ),
              );
            }
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(color: Color(0xFF1D9E75)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Statistik',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Data terkini persebaran',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              'assets/statistik.svg',
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChartCard(List<QueryDocumentSnapshot> docs, String field, String title) {
    if (docs.isEmpty) {
      return _buildEmptyCard(title, 'Belum ada data laporan');
    }

    Map<String, int> counts = {};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      String value = data[field] ?? '';
      if (value.isEmpty) value = 'Tidak Diketahui';
      counts[value] = (counts[value] ?? 0) + 1;
    }

    var sortedItems = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    int total = docs.length;
    List<Color> colors = [
      const Color(0xFF1D9E75),
      const Color(0xFFEF9F27),
      const Color(0xFF185FA5),
      const Color(0xFFE04F5F),
      const Color(0xFF8B5CF6),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0EDE7), width: 0.74),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 13, color: Color(0xFF222222)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Representasi Donut Chart riil
                SizedBox(
                  width: 90,
                  height: 90,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(90, 90),
                        painter: DonutChartPainter(
                          data: sortedItems.take(4).map((e) => e.value.toDouble()).toList(),
                          colors: colors.take(sortedItems.length < 4 ? sortedItems.length : 4).toList(),
                        ),
                      ),
                      Text(
                        '$total\nTotal',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Legends dynamically generated
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sortedItems.take(4).toList().asMap().entries.map((entry) {
                      int idx = entry.key;
                      var itemEntry = entry.value;
                      double pct = (itemEntry.value / total) * 100;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _buildLegendItem(
                          colors[idx % colors.length],
                          itemEntry.key,
                          '${pct.toStringAsFixed(1)}%',
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, String pct) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF444444)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          pct,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF222222),
          ),
        ),
      ],
    );
  }

  Widget _buildRankCard(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return _buildEmptyCard('Top Lokasi Terbanyak', 'Belum ada data laporan');
    }

    Map<String, int> districtCounts = {};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      String district = data['district'] ?? '';
      if (district.isEmpty) district = 'Tidak Diketahui';
      districtCounts[district] = (districtCounts[district] ?? 0) + 1;
    }

    var sortedDistricts = districtCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    int maxCount = sortedDistricts.isNotEmpty ? sortedDistricts.first.value : 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0EDE7), width: 0.74),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top 5 Kecamatan Terbanyak Berdasarkan Laporan',
              style: TextStyle(fontSize: 13, color: Color(0xFF222222)),
            ),
            const SizedBox(height: 24),
            ...sortedDistricts.take(5).toList().asMap().entries.map((entry) {
              int idx = entry.key;
              var districtEntry = entry.value;
              double fraction = districtEntry.value / maxCount;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: _buildRankItem('#${idx + 1}', districtEntry.key, districtEntry.value, fraction),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRankItem(String rank, String name, int count, double fraction) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            rank,
            style: const TextStyle(fontSize: 12, color: Color(0xFF1D9E75)),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            name,
            style: const TextStyle(fontSize: 12, color: Color(0xFF444444)),
            // Dihapus TextOverflow.ellipsis agar teksnya turun ke bawah dan tidak terpotong
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F5EE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: constraints.maxWidth * fraction,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D9E75),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            count.toString(),
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, color: Color(0xFF222222)),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCard(String title, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0EDE7), width: 0.74),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 13, color: Color(0xFF222222)),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                message,
                style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<double> data;
  final List<Color> colors;

  DonutChartPainter({required this.data, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double total = data.reduce((a, b) => a + b);
    double startAngle = -3.141592653589793 / 2; // Mulai dari arah jam 12 (-pi/2)
    final double strokeWidth = 14.0;
    
    final Rect rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width - strokeWidth,
      height: size.height - strokeWidth,
    );

    for (int i = 0; i < data.length; i++) {
      final double sweepAngle = (data[i] / total) * 2 * 3.141592653589793;
      
      final Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = colors[i]
        ..strokeCap = StrokeCap.butt; // Menggunakan butt agar sudutnya presisi berurutan

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      
      // Tambahkan gap kecil antar arc
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
