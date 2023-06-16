import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:if5250_rajin_apps_web/utils/util.dart';
import 'package:intl/intl.dart';

import 'cek.dart';
import 'sys_config.dart';

class Presensi {
  static const collectionName = 'presensi';
  final String? staffId;
  final String? jenis, ket, trxLog;
  final Timestamp timeCreate;
  final Timestamp? timeUpdate;
  final Cek checkIn;
  final Cek? checkOut;
  final bool? isLembur, isEdited;
  final String uid;

  String get waktuCekin {
    if (jenis == 'wfo' || jenis == 'wfh') {
      return checkIn.waktu.time;
    }
    return '-';
  }

  String get waktuCekout {
    if (jenis == 'wfo' || jenis == 'wfh') {
      return checkOut?.waktu.time ?? 'Belum';
    }
    return '-';
  }

  bool isTerlambat(MasterJamKerja masterJamKerja) {
    if (checkIn != null && masterJamKerja != null) {
      return masterJamKerja.jamMasuk.isBefore(checkIn.waktu.toDate());
    }
    return false;
  }

  bool isCepatPulang(MasterJamKerja masterJamKerja) {
    if (checkOut != null && masterJamKerja != null) {
      return masterJamKerja.jamPulang.isAfter(checkOut!.waktu.toDate());
    }
    return false;
  }

  Duration? selisihTelatMasuk(MasterJamKerja masterJamKerja) {
    if (checkIn != null && masterJamKerja != null) {
      return checkIn.waktu.toDate().difference(masterJamKerja.jamMasuk);
    }
    return null;
  }

  Duration? selisihCepatPulang(MasterJamKerja masterJamKerja) {
    if (checkOut != null && masterJamKerja != null) {
      return masterJamKerja.jamPulang.difference(checkOut!.waktu.toDate());
    }
    return null;
  }

  Duration? selisihDatangPulang(MasterJamKerja masterJamKerja) {
    if (checkOut != null) {
      return checkOut!.waktu.toDate().difference(checkIn.waktu.toDate());
    }
    return null;
  }

  String terlambat(MasterJamKerja masterJamKerja) {
    Duration? selisihTelatMasuk = this.selisihTelatMasuk(masterJamKerja);
    if (jenis == 'wfh' || jenis == 'wfo') {
      return (selisihTelatMasuk == null)
          ? '00:00:00'
          : '${(selisihTelatMasuk.inHours % 24).format2Dig}:${(selisihTelatMasuk.inMinutes % 60).format2Dig}:${(selisihTelatMasuk.inSeconds % 60).format2Dig}';
    }

    return '00:00:00';
  }

  String cepatPulang(MasterJamKerja masterJamKerja) {
    Duration? selisihCepatPulang = this.selisihCepatPulang(masterJamKerja);
    // print('selisihCepatPulang : ${selisihCepatPulang.inHours}');
    if (jenis == 'wfh' || jenis == 'wfo') {
      return (selisihCepatPulang == null)
          ? '00:00:00'
          : '${(selisihCepatPulang.inHours % 24).format2Dig}:${(selisihCepatPulang.inMinutes % 60).format2Dig}:${(selisihCepatPulang.inSeconds % 60).format2Dig}';
    }

    return '00:00:00';
  }

  String durasiKerja(MasterJamKerja masterJamKerja) {
    Duration? selisihDatangPulang = this.selisihDatangPulang(masterJamKerja);
    if (jenis == 'wfh' || jenis == 'wfo') {
      return (selisihDatangPulang == null)
          ? '00:00:00'
          : '${(selisihDatangPulang.inHours % 24).format2Dig}:${(selisihDatangPulang.inMinutes % 60).format2Dig}:${(selisihDatangPulang.inSeconds % 60).format2Dig}';
    }

    return '00:00:00';
  }

  String durasiLembur(MasterJamKerja masterJamKerja) {
    if (jenis == 'wfh' || jenis == 'wfo') {
      // jika lembur di hari kerja
      if (masterJamKerja != null &&
          this.checkIn.waktu.toDate().isWorkingDay()) {
        Duration selisihLembur =
            checkOut!.waktu.toDate().difference(masterJamKerja.jamPulang);
        return '${(selisihLembur.inHours % 24).format2Dig}:${(selisihLembur.inMinutes % 60).format2Dig}:${(selisihLembur.inSeconds % 60).format2Dig}';
      } else {
        // jika lembur diluar hari kerja
        Duration selisihLembur =
            checkOut!.waktu.toDate().difference(checkIn.waktu.toDate());
        return '${(selisihLembur.inHours % 24).format2Dig}:${(selisihLembur.inMinutes % 60).format2Dig}:${(selisihLembur.inSeconds % 60).format2Dig}';
      }
    }

    return '00:00:00';
  }

  Presensi(
      {required this.uid,
      required this.staffId,
      required this.jenis,
      required this.timeCreate,
      this.timeUpdate,
      required this.checkIn,
      this.checkOut,
      this.isLembur,
      this.isEdited,
      this.ket,
      this.trxLog});

  factory Presensi.fromJson(Map<String, dynamic> json) {
    return Presensi(
        uid: json['uid'],
        staffId: json['staff_id'],
        jenis: json['jenis'],
        timeCreate: json['time_create'],
        timeUpdate: json['time_update'],
        checkIn: Cek.fromJson(json['check_in']),
        checkOut: (json['check_out'] != null)
            ? Cek.fromJson(json['check_out'])
            : null,
        isLembur: (json.containsKey('is_lembur')) ? json['is_lembur'] : false,
        isEdited: (json.containsKey('is_edited')) ? json['is_edited'] : false,
        ket: json['ket'],
        trxLog: json['trx_log']);
  }
}

// fungsi untuk mendapatkan data presensi hari ini by nomor induk
Future<Presensi?> getTodayPresence(String noInduk,
    {bool isCekoutNull: false}) async {
  DateTime now = new DateTime.now();
  QuerySnapshot currPresensi;
  if (isCekoutNull) {
    currPresensi = await FirebaseFirestore.instance
        .collection('presensi')
        .where('staff_id', isEqualTo: noInduk)
        .where('check_in.waktu',
            isGreaterThanOrEqualTo: new DateTime(now.year, now.month, now.day))
        .where('check_in.waktu',
            isLessThan: new DateTime(now.year, now.month, now.day)
                .add(new Duration(days: 1)))
        .where('check_out', isEqualTo: null)
        .orderBy('check_in.waktu', descending: true)
        .limit(1)
        .get();
  } else {
    currPresensi = await FirebaseFirestore.instance
        .collection('presensi')
        .where('staff_id', isEqualTo: noInduk)
        .where('check_in.waktu',
            isGreaterThanOrEqualTo: new DateTime(now.year, now.month, now.day))
        .where('check_in.waktu',
            isLessThan: new DateTime(now.year, now.month, now.day)
                .add(new Duration(days: 1)))
        .orderBy('check_in.waktu', descending: true)
        .limit(1)
        .get();
  }

  Presensi? presensi = (currPresensi.docs.length > 0)
      ? Presensi.fromJson(currPresensi.docs[0].data() as Map<String, dynamic>)
      : null;
  // print("presensi : $presensi");
  return presensi;
}

extension TimestampExt on Timestamp {
  String get date {
    String date = DateFormat.yMMMMEEEEd().format(this.toDate());
    return dateIndo(date);
  }

  String get time {
    return DateFormat.Hms().format(this.toDate());
  }
}

extension DateTimeExt on DateTime {
  String get date {
    String date = DateFormat.yMMMMEEEEd().format(this);
    return dateIndo(date);
  }

  String get dateOnly {
    String date = DateFormat.yMMMMEEEEd().format(this);
    return dateOnlyIndo(date);
  }

  String get time {
    return DateFormat.Hms().format(this);
  }

  String get timeNoSec {
    return DateFormat.Hm().format(this);
  }
}

extension StringExt on String {
  String get removeSpace {
    return this.replaceAll(new RegExp(r"\s+"), "");
  }
}

extension IntExt on int {
  String get format2Dig {
    return this.toString().padLeft(2, '0');
  }
}

// fungsi untuk mendapatkan presensi dari list docs berdasarkan inputan datetime
Presensi? getFromDocs(List<QueryDocumentSnapshot>? docs, DateTime dateTime) {
  Presensi? presensi;
  docs?.forEach((element) {
    // print(element.data());
    Presensi getPresensi =
        Presensi.fromJson(element.data() as Map<String, dynamic>);
    /*
    uncomment for debugging purpose
    */
    // print('apakah ' +
    //     getPresensi.timeCreate.date +
    //     ' sama dengan ' +
    //     dateTime.date);
    if (getPresensi.timeCreate.date == dateTime.date) {
      presensi = getPresensi;
    }
  });
  return presensi;
}
