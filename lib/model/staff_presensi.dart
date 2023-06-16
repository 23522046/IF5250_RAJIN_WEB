import 'package:flutter/material.dart';

import 'staff.dart';

class StaffPresensi {
  final Staff staff;
  late List<PresensiExport> presensis;

  StaffPresensi({required this.staff}) {
    this.presensis = <PresensiExport>[];
  }

  set presensiExport(PresensiExport export) {
    this.presensis.add(export);
  }
}

class PresensiExport {
  final DateTime? tglAsli;
  final bool? isLembur, isEdited;
  final String? hari,
      tanggal,
      jamKerja,
      kegiatan,
      terlambat,
      cepatPulang,
      jamEfektif,
      lembur,
      ket;
  final TextWStyle? jamMasuk, jamKeluar;

  PresensiExport(
      {this.tglAsli,
      this.isLembur,
      this.hari,
      this.jamMasuk,
      this.cepatPulang,
      this.jamEfektif,
      this.jamKeluar,
      this.jamKerja,
      this.kegiatan,
      this.lembur,
      this.tanggal,
      this.terlambat,
      this.isEdited,
      this.ket});
}

class TextWStyle {
  final Color color;
  final String? text;

  TextWStyle({this.color: Colors.black87, this.text});
}
