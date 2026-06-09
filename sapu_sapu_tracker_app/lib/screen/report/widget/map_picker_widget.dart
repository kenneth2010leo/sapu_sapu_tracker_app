import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapPickerWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng currentLocation;
  final VoidCallback onMapReady;
  final VoidCallback onMyLocationPressed;
  final void Function(MapCamera, bool) onPositionChanged;
  final void Function(MapEvent) onMapEvent;

  const MapPickerWidget({
    super.key,
    required this.mapController,
    required this.currentLocation,
    required this.onMapReady,
    required this.onMyLocationPressed,
    required this.onPositionChanged,
    required this.onMapEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0EDE7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: currentLocation,
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onMapReady: onMapReady,
                onPositionChanged: onPositionChanged,
                onMapEvent: onMapEvent,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://api.maptiler.com/maps/streets-v2/256/{z}/{x}/{y}.png?key=${dotenv.env['MAPTILER_API_KEY']}',
                  userAgentPackageName: 'com.sapusaputracker.app',
                ),
              ],
            ),
            // Center Marker
            const Center(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 40.0,
                ), // Offset to make tip point to center
                child: Icon(
                  Icons.location_on,
                  color: Color(0xFFD32F2F),
                  size: 40,
                ),
              ),
            ),
            // My Location Button
            Positioned(
              right: 12,
              bottom: 12,
              child: FloatingActionButton(
                heroTag: 'myLocationBtn',
                mini: true,
                backgroundColor: Colors.white,
                onPressed: onMyLocationPressed,
                child: const Icon(
                  Icons.my_location,
                  color: Color(0xFF1D9E75),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
