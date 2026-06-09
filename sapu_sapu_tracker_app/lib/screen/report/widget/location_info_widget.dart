import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart' hide Path;

class LocationInfoWidget extends StatelessWidget {
  final LatLng currentLocation;
  final TextEditingController addressController;
  final VoidCallback onCoordinateTap;
  final void Function(String)? onSearch;

  const LocationInfoWidget({
    super.key,
    required this.currentLocation,
    required this.addressController,
    required this.onCoordinateTap,
    this.onSearch,
  });

  Widget _buildReadOnlyInput({
    required String iconPath,
    required String text,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0EDE7), width: 0.74),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SvgPicture.asset(iconPath, width: 16, height: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0EDE7), width: 0.74),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 14.0),
            child: Icon(Icons.map_outlined, size: 16, color: Color(0xFF888888)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: addressController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.search,
              onSubmitted: onSearch,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintText: 'Cari otomatis atau ketik patokan spesifik...',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFBBBBBB),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Color(0xFF1D9E75)),
                  onPressed: () {
                    if (onSearch != null) {
                      onSearch!(addressController.text);
                    }
                  },
                ),
              ),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF222222),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReadOnlyInput(
          iconPath: 'assets/for_app/lokasi_gps.svg',
          text: '${currentLocation.latitude.toStringAsFixed(4)}, ${currentLocation.longitude.toStringAsFixed(4)}',
          textColor: const Color(0xFF1D9E75),
          onTap: onCoordinateTap,
        ),
        const SizedBox(height: 16),
        const Text(
          'Alamat Lengkap / Patokan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 8),
        _buildAddressDisplay(),
      ],
    );
  }
}
