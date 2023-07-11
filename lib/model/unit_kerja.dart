import 'package:cloud_firestore/cloud_firestore.dart';

import 'batas_wilayah.dart';
import 'jam_kerja.dart';

class UnitKerja {
  final String idDoc;
  final String? nama, level;
  final DocumentReference? parent;
  final List<BatasWilayah>? batasWilayah;
  final List<JamKerja>? jamKerja;
  UnitKerja? unitKerjaParentCol;

  static const collectionName = 'unit_kerja';

  UnitKerja(
      {this.nama,
      this.level,
      this.parent,
      required this.idDoc,
      this.batasWilayah,
      this.jamKerja,
      this.unitKerjaParentCol});

  @override
  String toString() {
    return "idDoc : $idDoc, nama : $nama, level : $level, parent : $parent, batas_wilayah : $batasWilayah, jam_kerja : $jamKerja";
  }

  factory UnitKerja.fromJson(Map<String, dynamic> json, String idDoc) {
    return UnitKerja(
      idDoc: idDoc,
      nama: json['nama'],
      level: json['level'],
      parent: json['parent'],
      batasWilayah: (json['batas_wilayah'] == null)
          ? null
          : (json['batas_wilayah'] as List<dynamic>)
              .map((e) => BatasWilayah.fromJson(e))
              .toList(),
      jamKerja: (json['jam_kerja'] == null)
          ? null
          : (json['jam_kerja'] as List<dynamic>)
              .map((e) => JamKerja.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'level': level,
      'parent': parent,
      'batas_wilayah': batasWilayah?.map((w) => w.toJson()).toList()
    };
  }
}
