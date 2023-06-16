import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Wilayah {
  final String? nama;
  final List<GeoPoint>? polygons;

  Wilayah({this.nama, this.polygons});

  factory Wilayah.fromJson(Map<String, dynamic> json) {
    return Wilayah(
        nama: json['nama'],
        polygons: (json['polygons'] == null
            ? []
            : (json['polygons']).map((j) => j).toList()));
  }
}
