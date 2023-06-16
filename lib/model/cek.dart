import 'package:cloud_firestore/cloud_firestore.dart';

class Cek {
  final Timestamp waktu;
  final bool isMockLocation;
  final GeoPoint location;

  Cek(
      {required this.waktu,
      required this.isMockLocation,
      required this.location});

  factory Cek.fromJson(Map<String, dynamic> json, {bool isWorking: true}) {
    return Cek(
        isMockLocation: json['is_mock_location'],
        waktu: (isWorking)
            ? json['waktu']
            : null, // jika tidak working, waktu cek tidak perlu diambil
        location: json['location']);
  }

  Map<String, dynamic> toJson() {
    return {
      'waktu': waktu,
      'location': location,
      'is_mock_location': isMockLocation,
    };
  }
}
