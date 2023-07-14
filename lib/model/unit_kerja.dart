import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:if5250_rajin_apps_web/model/staff.dart';

import 'batas_wilayah.dart';
import 'jam_kerja.dart';

class UnitKerja {
  final String idDoc;
  final String? nama, level;
  final DocumentReference? parent;
  final List<BatasWilayah>? batasWilayah;
  final List<JamKerja>? jamKerja;
  final bool? isTopParent;
  UnitKerja? unitKerjaParentCol;
  List<Staff>? adminStaffs;

  static const collectionName = 'unit_kerja';

  UnitKerja(
      {this.nama,
      this.level,
      this.parent,
      required this.idDoc,
      this.batasWilayah,
      this.jamKerja,
      this.unitKerjaParentCol,
      this.isTopParent,
      this.adminStaffs});

  @override
  String toString() {
    return "idDoc : $idDoc, nama : $nama, level : $level, parent : $parent, batas_wilayah : $batasWilayah, jam_kerja : $jamKerja, is_top_parent : $isTopParent";
  }

  factory UnitKerja.fromJson(Map<String, dynamic> json, String idDoc) {
    return UnitKerja(
      idDoc: idDoc,
      nama: json['nama'],
      level: json['level'],
      parent: json['parent'],
      isTopParent: json['is_top_parent'],
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
      'batas_wilayah': batasWilayah?.map((w) => w.toJson()).toList(),
      'is_top_parent': isTopParent
    };
  }

  String adminStaffToString() {
    String res = '';
    adminStaffs?.forEach((s) {
      res += "${s.nama} - ${s.noInduk}\n";
    });
    return res;
  }
}
