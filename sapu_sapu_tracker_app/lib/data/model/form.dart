import 'package:cloud_firestore/cloud_firestore.dart'; //geopoint

class Form {
  final String formId;
  final String userId;
  final GeoPoint koordinatGps;
  final String namaLokasi;
  final String? catatan; //opsional
  final DateTime tanggalInput;

  Form({
    required this.formId,
    required this.userId,
    required this.namaLokasi,
    required this.koordinatGps,
    this.catatan,
    required this.tanggalInput,
  });

  factory Form.fromJson(Map<String, dynamic> json) {
    return Form(
      formId: json['formId'] ?? '',
      userId: json['userId'] ?? '',
      namaLokasi: json['namaLokasi'] ?? '',
      //kosong diberi 0,0
      koordinatGps: json['koordinatGps'] ?? const GeoPoint(0.0, 0.0),
      catatan: json['catatan'], 
      tanggalInput: json['tanggalInput'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['tanggalInput'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formId': formId,
      'userId': userId,
      'namaLokasi': namaLokasi,
      'koordinatGps': koordinatGps,
      'catatan': catatan,
      'tanggalInput': tanggalInput.millisecondsSinceEpoch,
    };
  }
}