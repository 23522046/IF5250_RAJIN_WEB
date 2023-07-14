import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:if5250_rajin_apps_web/model/unit_kerja.dart';

import 'sys_config.dart';

class Staff {
  static const collectionName = 'staff';
  String? UID, nama, noInduk, playerId;
  Timestamp? timeCreate;
  bool? isAktif, isSuperUser;
  DocumentReference? unitKerja;
  DocumentReference? unitKerjaParentAdmin;
  DocumentReference? unitKerjaParent;
  UnitKerja? unitKerjaParentCol;
  String? unitKerjaParentName;

  int?
      jumlahHadir; // digunakan pada laporan uang makan, diisi dengan jumlah hadir per bulan

  Staff(
      {this.noInduk,
      this.nama,
      this.unitKerja,
      this.timeCreate,
      this.isAktif,
      this.unitKerjaParentAdmin,
      this.jumlahHadir,
      this.playerId,
      this.UID,
      this.unitKerjaParent,
      this.unitKerjaParentName,
      this.unitKerjaParentCol,
      this.isSuperUser});

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
        noInduk: json['no_induk'],
        nama: json['nama'],
        unitKerja: json['unit_kerja'],
        timeCreate: json['time_create'],
        isAktif: json['is_aktif'],
        unitKerjaParentAdmin: json['unit_kerja_parent_admin'],
        playerId: json['player_id'],
        UID: json['UID']);
  }

  Map<String, dynamic> toJson() {
    return {
      'UID': UID,
      'is_aktif': true,
      'nama': nama,
      'no_induk': noInduk,
      'player_id': playerId,
      'time_create': timeCreate,
      'unit_kerja': unitKerja,
      'unit_kerja_parent_admin': unitKerjaParentAdmin
    };
  }
}
