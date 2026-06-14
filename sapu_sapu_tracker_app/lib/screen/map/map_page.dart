import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sapu_sapu_tracker_app/data/firestore_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(-7.5000, 110.0000), // Tengah Pulau Jawa
        initialZoom: 6.5,
        minZoom:
            5.0, // Membatasi agar tidak bisa zoom out sampai ke seluruh dunia
        maxZoom: 18.0,
        // Mematikan rotasi (putaran) agar peta tidak miring/bergeser saat di-zoom
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          // --- MAPTILER TILE URL ---
          urlTemplate:
              'https://api.maptiler.com/maps/streets-v2/256/{z}/{x}/{y}.png?key=${dotenv.env['MAPTILER_API_KEY']}',
          userAgentPackageName: 'com.example.sapu_sapu_tracker_app',
          keepBuffer:
              10, // Menjaga tile di memori agar tidak selalu loading saat geser peta
        ),
        StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getApprovedReportsStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Gagal memuat data'));
            }

            // Dihapus pengecekan ConnectionState.waiting agar MarkerLayer tidak terganti
            // oleh CircularProgressIndicator yang membuat layar peta berkedip putih/loading.

            final docs = snapshot.data?.docs ?? [];

            final markers = docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final lat = data['lat'] ?? 0.0;
              final lng = data['lng'] ?? 0.0;

              return Marker(
                point: LatLng(lat, lng),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () => _showReportDetails(context, data),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D9E75),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons
                          .set_meal, // Ikon ikan bawaan Flutter sebagai pengganti SVG
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              );
            }).toList();

            return MarkerLayer(markers: markers);
          },
        ),
      ],
    );
  }

  void _showReportDetails(
    BuildContext context,
    Map<String, dynamic> reportData,
  ) {
    final String fullAddress = reportData['fullAddress']?.toString() ?? '';
    final String fallbackAddress =
        '${reportData['district']}, ${reportData['city']}, ${reportData['province']}';
    final String address = fullAddress.isNotEmpty
        ? fullAddress
        : fallbackAddress;

    final String rawDesc = reportData['description'] ?? 'Tidak ada catatan';
    String desc = rawDesc;
    // Ekstrak angka pertama dari deskripsi e.g. "12 ekor ikan..."
    final match = RegExp(r'^(\d+)').firstMatch(rawDesc);
    if (match != null) {
      desc = '${match.group(1)} Ikan Sapu-Sapu ditemukan';
    }

    final double lat = reportData['lat'] ?? 0.0;
    final double lng = reportData['lng'] ?? 0.0;

    final timestamp = reportData['timestamp'] as Timestamp?;
    String timeStr = 'Waktu tidak diketahui';
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

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0EDE7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F5EE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text('🐟', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF222222),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 12,
                              color: Color(0xFF888888),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF888888),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.access_time,
                              size: 12,
                              color: Color(0xFF888888),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeStr,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Catatan Lapangan:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF444444),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAF8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE0EDE7),
                    width: 0.74,
                  ),
                ),
                child: Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
