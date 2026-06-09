import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sapu_sapu_tracker_app/data/firestore_service.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'widget/photo_upload_widget.dart';
import 'widget/map_picker_widget.dart';
import 'widget/quantity_input_widget.dart';
import 'widget/location_info_widget.dart';

class CreateReportPage extends StatefulWidget {
  const CreateReportPage({super.key});

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  int _fishCount = 0;
  LatLng? _currentLocation; // Kosong di awal untuk memicu loading
  final MapController _mapController = MapController();
  final TextEditingController _fishCountController = TextEditingController(text: '0');
  
  List<File> _selectedImages = [];
  String _province = '';
  String _city = '';
  String _district = '';
  final TextEditingController _addressController = TextEditingController(text: 'Mencari lokasi...');
  bool _isSubmitting = false;
  
  final TextEditingController _descController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    // Meminta lokasi (dan permission) saat pertama kali buka halaman
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    _fishCountController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentLocation = const LatLng(-6.2088, 106.8456); // Default Jakarta
        _addressController.text = 'Layanan lokasi tidak aktif.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentLocation = const LatLng(-6.2088, 106.8456);
          _addressController.text = 'Izin lokasi ditolak.';
        });
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentLocation = const LatLng(-6.2088, 106.8456);
        _addressController.text = 'Izin lokasi ditolak permanen.';
      });
      return;
    } 

    try {
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            timeLimit: Duration(seconds: 5),
          ),
        );
      } catch (e) {
        // Jika gagal/timeout, coba ambil last known
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        throw Exception("Tidak ada data lokasi");
      }
      
      final pos = position;
      setState(() {
        _currentLocation = LatLng(pos.latitude, pos.longitude);
      });
      _mapController.move(_currentLocation!, 15.0);
      _updateAddress(_currentLocation!);
    } catch (e) {
      debugPrint("Error getCurrentLocation: $e");
      setState(() {
        _currentLocation = const LatLng(-6.2088, 106.8456); // Default Jakarta
        if (e.toString().contains('Timeout')) {
          _addressController.text = 'GPS Lemah (Di dalam ruangan). Geser peta manual.';
        } else {
          _addressController.text = 'Gagal baca GPS: $e';
        }
      });
    }
  }

  Future<void> _updateAddress(LatLng position) async {
    setState(() {
      _addressController.text = 'Menerjemahkan koordinat...';
    });
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _province = place.administrativeArea ?? '';
          _city = place.subAdministrativeArea ?? '';
          _district = place.locality ?? place.subLocality ?? '';
          
          List<String> fullParts = [];
          
          // Native geocoder kadang mengembalikan plus code di 'name' atau 'street' jika jalan tak bernama, 
          // jadi kita abaikan jika mengandung karakter '+'.
          if (place.street != null && place.street!.isNotEmpty && !place.street!.contains('+')) {
            fullParts.add(place.street!);
          } else if (place.name != null && place.name!.isNotEmpty && !place.name!.contains('+')) {
            fullParts.add(place.name!);
          }
          
          if (_district.isNotEmpty && !fullParts.contains(_district)) fullParts.add(_district);
          if (_city.isNotEmpty && !fullParts.contains(_city)) fullParts.add(_city);
          if (_province.isNotEmpty && !fullParts.contains(_province)) fullParts.add(_province);
          
          _addressController.text = fullParts.join(', ');
        });
      }
    } catch (e) {
      debugPrint("Native geocoding failed ($e), trying OSM Nominatim...");
      try {
        final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1');
        final response = await http.get(url, headers: {'User-Agent': 'sapu_sapu_tracker_app/1.0'});
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final address = data['address'] as Map<String, dynamic>? ?? {};
          
          setState(() {
            _province = address['state'] ?? address['province'] ?? '';
            _city = address['city'] ?? address['county'] ?? address['municipality'] ?? address['region'] ?? '';
            _district = address['suburb'] ?? address['town'] ?? address['village'] ?? address['district'] ?? address['neighbourhood'] ?? '';
            
            if (data['display_name'] != null && data['display_name'].toString().isNotEmpty) {
              _addressController.text = data['display_name'].toString();
            } else {
              List<String> addressParts = [];
              if (_district.isNotEmpty) addressParts.add(_district);
              if (_city.isNotEmpty) addressParts.add(_city);
              if (_province.isNotEmpty) addressParts.add(_province);
              
              if (addressParts.isEmpty) {
                _addressController.text = 'Alamat tidak diketahui';
              } else {
                _addressController.text = addressParts.join(', ');
              }
            }
          });
        } else {
          throw Exception("Nominatim Error ${response.statusCode}");
        }
      } catch (fallbackError) {
        debugPrint("OSM fallback failed: $fallbackError");
        setState(() {
          _addressController.text = 'Gagal baca lokasi (Periksa Internet)';
        });
      }
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) return;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mencari lokasi...'), duration: Duration(seconds: 1)),
      );
    }

    try {
      // 1. Coba Native Geocoding
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        setState(() {
          _currentLocation = LatLng(loc.latitude, loc.longitude);
        });
        _mapController.move(_currentLocation!, 15.0);
        return;
      }
    } catch (e) {
      debugPrint("Native search failed ($e), trying Nominatim search...");
      // 2. Coba OSM Nominatim Search sebagai fallback
      try {
        final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1');
        final response = await http.get(url, headers: {'User-Agent': 'sapu_sapu_tracker_app/1.0'});
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as List;
          if (data.isNotEmpty) {
            final lat = double.parse(data[0]['lat']);
            final lon = double.parse(data[0]['lon']);
            setState(() {
              _currentLocation = LatLng(lat, lon);
            });
            _mapController.move(_currentLocation!, 15.0);
            return;
          }
        }
      } catch (e2) {
        debugPrint("Nominatim search failed: $e2");
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi tidak ditemukan.')),
      );
    }
  }

  Future<void> _submitReport() async {
    if (_currentLocation == null) return;

    // Validasi Pulau Jawa Constraint
    if (_currentLocation!.latitude < -8.78 || _currentLocation!.latitude > -5.87 ||
        _currentLocation!.longitude < 105.09 || _currentLocation!.longitude > 114.60) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maaf, aplikasi ini saat ini hanya melayani area Pulau Jawa.')),
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus menambahkan minimal 1 foto ikan.')),
      );
      return;
    }

    if (_fishCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah ikan yang ditemukan tidak boleh 0 atau minus')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final reportedBy = currentUser?.email ?? "Pengguna Aplikasi";

      await _firestoreService.addReport(
        lat: _currentLocation!.latitude,
        lng: _currentLocation!.longitude,
        province: _province,
        city: _city,
        district: _district,
        fullAddress: _addressController.text, // MENGGUNAKAN FULL ADDRESS DARI TEXTFIELD
        reportedBy: reportedBy,
        description: _descController.text.isNotEmpty ? _descController.text : "$_fishCount ekor ikan sapu-sapu ditemukan",
        status: "pending",
        imageFiles: _selectedImages,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil dikirim!'),
            backgroundColor: Color(0xFF1D9E75),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim laporan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      PhotoUploadWidget(
                        images: _selectedImages,
                        onImageAdded: (file) {
                          setState(() {
                            _selectedImages.add(file);
                          });
                        },
                        onImageRemoved: (file) {
                          setState(() {
                            _selectedImages.remove(file);
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildLabel('Pilih Lokasi Kejadian'),
                      const SizedBox(height: 8),
                      if (_currentLocation == null)
                        Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0EDE7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Color(0xFF1D9E75)),
                                SizedBox(height: 12),
                                Text('Mengambil lokasi saat ini...', style: TextStyle(color: Color(0xFF1D9E75), fontSize: 13)),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        MapPickerWidget(
                          mapController: _mapController,
                          currentLocation: _currentLocation!,
                          onMapReady: _getCurrentLocation,
                          onMyLocationPressed: _getCurrentLocation,
                          onPositionChanged: (position, hasGesture) {
                            if (hasGesture) {
                              setState(() {
                                _currentLocation = position.center;
                              });
                            }
                          },
                          onMapEvent: (event) {
                            if (event is MapEventMoveEnd) {
                              _updateAddress(_currentLocation!);
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        LocationInfoWidget(
                          currentLocation: _currentLocation!,
                          addressController: _addressController, // Menggunakan controller
                          onCoordinateTap: _showManualCoordinateDialog,
                          onSearch: _searchAddress, // Panggil method search
                        ),
                      ],
                      const SizedBox(height: 16),
                      _buildLabel('Estimasi Jumlah Ikan Ditemukan'),
                      const SizedBox(height: 8),
                      QuantityInputWidget(
                        controller: _fishCountController,
                        onDecrement: () {
                          if (_fishCount > 1) {
                            setState(() {
                              _fishCount--;
                              _fishCountController.text = _fishCount.toString();
                            });
                          }
                        },
                        onIncrement: () {
                          setState(() {
                            _fishCount++;
                            _fishCountController.text = _fishCount.toString();
                          });
                        },
                        onTap: () {
                          if (_fishCountController.text == '0') {
                            _fishCountController.clear();
                          }
                        },
                        onChanged: (value) {
                          if (value == '0') {
                            _fishCountController.text = '';
                            setState(() { _fishCount = 0; });
                            return;
                          }
                          setState(() {
                            _fishCount = int.tryParse(value) ?? 0;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Catatan (opsional)'),
                      const SizedBox(height: 8),
                      _buildTextArea('Tambahkan deskripsi kondisi, habitat, dll...'),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                      const SizedBox(height: 32), // Bottom padding
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1D9E75),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: SvgPicture.asset(
                'assets/for_app/back.svg',
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buat Laporan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Laporkan temuan ikan sapu-sapu',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextArea(String hintText) {
    return Container(
      width: double.infinity,
      height: 94,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0EDE7), width: 0.74),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _descController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xFFBBBBBB),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF222222),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return InkWell(
      onTap: _isSubmitting ? null : _submitReport,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: _isSubmitting ? const Color(0xFF8BCDAF) : const Color(0xFF1D9E75),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isSubmitting)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              SvgPicture.asset('assets/for_app/kirim_lokasi.svg', width: 18, height: 18),
            const SizedBox(width: 8),
            Text(
              _isSubmitting ? 'Mengirim...' : 'Kirim Laporan',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF222222),
      ),
    );
  }

  void _showManualCoordinateDialog() {
    final TextEditingController latCtrl = TextEditingController(text: _currentLocation!.latitude.toString());
    final TextEditingController lngCtrl = TextEditingController(text: _currentLocation!.longitude.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Input Koordinat Manual', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: latCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(labelText: 'Latitude (Lintang)'),
              ),
              TextField(
                controller: lngCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(labelText: 'Longitude (Bujur)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                final lat = double.tryParse(latCtrl.text);
                final lng = double.tryParse(lngCtrl.text);
                if (lat != null && lng != null) {
                  setState(() {
                    _currentLocation = LatLng(lat, lng);
                  });
                  _mapController.move(_currentLocation!, 15.0);
                  _updateAddress(_currentLocation!);
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan', style: TextStyle(color: Color(0xFF1D9E75), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}


