import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:if5250_rajin_apps_web/model/staff.dart';

import '../utils/util.dart';
import 'cek.dart';

class Pengajuan {
  final String? docId;

  final List<String>? dokPendukung;
  final String? jenis, staffId, status, ket, uid;
  final List<Log>? log;
  final Timestamp? mulaiTanggal, sampaiTanggal, timeCreate;
  Staff?
      staff; // digunakan pada view pengajuan, sebagai relasi ke collection staff

  Pengajuan(
      {this.docId,
      this.dokPendukung,
      this.jenis,
      this.log,
      this.mulaiTanggal,
      this.sampaiTanggal,
      this.staffId,
      this.status,
      this.timeCreate,
      this.staff,
      this.ket,
      this.uid});

  String get logAktifitas {
    String res = '';
    log?.forEach((l) {
      res += '${l.deskripsi} pada ${formatDate(l.time!.toDate())}\n';
    });
    return res;
  }

  factory Pengajuan.fromJson(Map<String, dynamic> json, String docId,
      {Staff? staff}) {
    return Pengajuan(
        staff: staff,
        docId: docId,
        dokPendukung: List<String>.from(json['dok_pendukung']),
        jenis: json['jenis'],
        log: (json['log'] == null)
            ? null
            : (json['log'] as List).map((json) => Log.fromJson(json)).toList(),
        mulaiTanggal: json['mulai_tanggal'],
        sampaiTanggal: json['sampai_tanggal'],
        timeCreate: json['time_create'],
        staffId: json['staff_id'],
        status: json['status'],
        ket: json['ket'],
        uid: json['uid']);
  }
}

class Log {
  final String? deskripsi, staffId, status;
  final Timestamp? time;

  Log({this.deskripsi, this.staffId, this.status, this.time});

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
        deskripsi: json['deskripsi'],
        staffId: json['staff_id'],
        status: json['status'],
        time: json['time']);
  }

  Map<String, dynamic> toJson() {
    return {
      'deskripsi': deskripsi,
      'staff_id': staffId,
      'status': status,
      'time': time
    };
  }
}
