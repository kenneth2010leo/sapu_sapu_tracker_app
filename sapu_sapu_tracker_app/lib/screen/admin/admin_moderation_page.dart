import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sapu_sapu_tracker_app/data/firestore_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdminModerationPage extends StatelessWidget {
  const AdminModerationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        title: const Text(
          'Kelola Laporan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF1D9E75),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getPendingReportsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1D9E75)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Terjadi kesalahan:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Color(0xFF8BCDAF),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Semua laporan sudah diperiksa!',
                    style: TextStyle(color: Color(0xFF888888), fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final String reporter = data['reportedBy'] ?? 'Unknown';
              final String description =
                  data['description'] ?? 'Tidak ada deskripsi';
              final String fallbackAddress =
                  '${data['district'] ?? ''}, ${data['city'] ?? ''}';
              final String fullAddress = data['fullAddress']?.toString() ?? '';
              final String address = fullAddress.isNotEmpty
                  ? fullAddress
                  : fallbackAddress;
              final List<dynamic> images = data['imageUrls'] ?? [];
              final double lat = data['lat'] ?? 0.0;
              final double lng = data['lng'] ?? 0.0;

              return Card(
                margin: const EdgeInsets.only(bottom: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 16,
                            color: Color(0xFF888888),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              reporter,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Menunggu',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Text(description, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 16),

                      // Bagian Map
                      const Text(
                        'Lokasi Temuan:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF888888),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Color(0xFFE24B4A),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (lat != 0.0 && lng != 0.0)
                        Container(
                          height:
                              250, // Diperbesar dari 150 agar map lebih lebar/tinggi ke bawah
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE0EDE7)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(lat, lng),
                                initialZoom: 15.0,
                                interactionOptions: const InteractionOptions(
                                  flags:
                                      InteractiveFlag.all &
                                      ~InteractiveFlag.rotate,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://api.maptiler.com/maps/streets-v2/256/{z}/{x}/{y}.png?key=${dotenv.env['MAPTILER_API_KEY']}',
                                  userAgentPackageName:
                                      'com.example.sapu_sapu_tracker_app',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(lat, lng),
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Bagian Foto
                      const Text(
                        'Foto Bukti:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF888888),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (images.isNotEmpty) ...[
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            itemBuilder: (context, imgIndex) {
                              return GestureDetector(
                                onTap: () =>
                                    _showFullImage(context, images[imgIndex]),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  width: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE0EDE7),
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        images[imgIndex],
                                      ), // Menggunakan NetworkImage bawaan Flutter
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4F4),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFFD6D6)),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.broken_image,
                                color: Color(0xFFE24B4A),
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Pelapor tidak menyertakan foto bukti',
                                  style: TextStyle(
                                    color: Color(0xFFE24B4A),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _handleAction(
                                context,
                                firestoreService,
                                doc.id,
                                'rejected',
                              ),
                              icon: const Icon(
                                Icons.close,
                                color: Color(0xFFE24B4A),
                              ),
                              label: const Text(
                                'Tolak',
                                style: TextStyle(color: Color(0xFFE24B4A)),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFE24B4A),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _handleAction(
                                context,
                                firestoreService,
                                doc.id,
                                'approved',
                              ),
                              icon: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Setujui',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1D9E75),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, color: Colors.white, size: 64),
          ),
        ),
      ),
    );
  }

  void _handleAction(
    BuildContext context,
    FirestoreService service,
    String docId,
    String status,
  ) async {
    try {
      await service.updateReportStatus(docId, status);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'approved'
                  ? 'Laporan disetujui ✅'
                  : 'Laporan ditolak ❌',
            ),
            backgroundColor: status == 'approved'
                ? const Color(0xFF1D9E75)
                : const Color(0xFFE24B4A),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }
}
