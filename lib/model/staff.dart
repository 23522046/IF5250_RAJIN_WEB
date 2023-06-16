import 'package:cloud_firestore/cloud_firestore.dart';

import 'sys_config.dart';

class Staff {
  static const collectionName = 'staff';
  String? noInduk,
      nama,
      password,
      unitKerja,
      email,
      hp,
      jabatanStruktural,
      jabatanFungsional,
      pangkatGolongan,
      tokenReset,
      jenisPegawai,
      jenisAkunWeb,
      jenisTenaga,
      grade,
      playerId,
      UID;
  Timestamp? timeCreate, timeUpdate;
  bool? isAktif;
  DocumentReference? unitKerjaRef;

  int?
      jumlahHadir; // digunakan pada laporan uang makan, diisi dengan jumlah hadir per bulan

  Staff(
      {this.noInduk,
      this.nama,
      this.password,
      this.unitKerja,
      this.email,
      this.hp,
      this.jabatanStruktural,
      this.jabatanFungsional,
      this.pangkatGolongan,
      this.timeCreate,
      this.timeUpdate,
      this.isAktif,
      this.tokenReset,
      this.jenisAkunWeb,
      this.jenisPegawai,
      this.jenisTenaga,
      this.jumlahHadir,
      this.grade,
      this.playerId,
      this.unitKerjaRef,
      this.UID});

  bool get isAdminUnit => (jenisAkunWeb == 'Administrator Unit') ? true : false;

  bool get isUntracked =>
      SysConfig.listUntrackedUser().contains(noInduk) ? true : false;

  bool get isAdminSistem =>
      (jenisAkunWeb == 'Administrator Sistem') ? true : false;

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
        noInduk: json['no_induk'],
        nama: json['nama'],
        password: json['password'] ?? null,
        unitKerjaRef: json['unit_kerja'],
        email: json['email'],
        hp: json['hp'],
        jabatanStruktural: json['jabatan_struktural'],
        jabatanFungsional: json['jabatan_fungsional'],
        pangkatGolongan: json['pangkat_golongan'],
        timeCreate: json['time_create'],
        timeUpdate: json['time_update'],
        isAktif: json['is_aktif'],
        tokenReset: (json['token_reset'] != null) ? json['token_reset'] : null,
        jenisAkunWeb: json['jenis_akun_web'],
        jenisPegawai: json['jenis_pegawai'] ?? 'Non PNS',
        jenisTenaga: json['jenis_tenaga'],
        grade: json['grade'],
        playerId: json['player_id'],
        UID: json[
            'UID']); // sementara jika pegawai bleum update data akan dibaca sebagai Non PNS
  }
}
