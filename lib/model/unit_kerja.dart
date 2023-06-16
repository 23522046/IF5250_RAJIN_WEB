import 'package:cloud_firestore/cloud_firestore.dart';

class UnitKerja {
  final String? nama, level;
  final DocumentReference? parent;

  UnitKerja({this.nama, this.level, this.parent});

  factory UnitKerja.fromJson(Map<String, dynamic> json) {
    return UnitKerja(
        nama: json['nama'], level: json['level'], parent: json['parent']);
  }
}
