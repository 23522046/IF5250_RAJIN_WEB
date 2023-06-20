import 'package:cloud_firestore/cloud_firestore.dart';

class UnitKerja {
  final String? nama, level, idDoc;
  final DocumentReference? parent;

  UnitKerja({this.nama, this.level, this.parent, this.idDoc});

  @override
  String toString() {
    return "idDoc : $idDoc, nama : $nama, level : $level, parent : $parent";
  }

  factory UnitKerja.fromJson(Map<String, dynamic> json, {String? idDoc}) {
    return UnitKerja(
        idDoc: idDoc,
        nama: json['nama'],
        level: json['level'],
        parent: json['parent']);
  }
}
