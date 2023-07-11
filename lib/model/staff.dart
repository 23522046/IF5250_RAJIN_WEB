import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:if5250_rajin_apps_web/model/unit_kerja.dart';

import 'sys_config.dart';

class Staff {
  static const collectionName = 'staff';
  String? UID, nama, noInduk, playerId;
  Timestamp? timeCreate;
  bool? isAktif, isAdminWeb;
  DocumentReference? unitKerja;
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
      this.isAdminWeb,
      this.jumlahHadir,
      this.playerId,
      this.UID,
      this.unitKerjaParent,
      this.unitKerjaParentName,
      this.unitKerjaParentCol});

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
        noInduk: json['no_induk'],
        nama: json['nama'],
        unitKerja: json['unit_kerja'],
        timeCreate: json['time_create'],
        isAktif: json['is_aktif'],
        isAdminWeb: json['isAdminWeb'],
        playerId: json['player_id'],
        UID: json['UID']);
  }
}
