import 'package:cloud_firestore/cloud_firestore.dart';

class BatasWilayah {
  final String? nama;
  final List<GeoPoint>? polygons;

  BatasWilayah({required this.nama, required this.polygons});

  factory BatasWilayah.fromJson(Map<String, dynamic> json) {
    return BatasWilayah(
        nama: json['nama'],
        polygons: (json['polygons'] as List)
            .map((e) => GeoPoint(e.latitude, e.longitude))
            .toList());
  }

  polygonsFormatted() {
    String res = '';
    polygons?.forEach((p) {
      res += '[${p.latitude}, ${p.longitude}],\n';
    });
    return res;
  }

  Map<String, dynamic> toJson() {
    return {'nama': nama, 'polygons': polygons};
  }
}
