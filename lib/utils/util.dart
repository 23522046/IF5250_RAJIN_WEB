import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/staff.dart';
import '../model/sys_config.dart';
import '../model/unit_kerja.dart';

enum RadioDay { work_day, all_day, overtime_only }

Future sendNotif(List<String> playerIds, String title, String subtitle) async {
  Response response;
  Dio dio = new Dio();
  String route = 'https://onesignal.com/api/v1/notifications';

  try {
    Options options = Options(headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Basic OTExMTUwMWEtYWMwNi00NzExLTk0NDQtYzdiMzE0YWViNzNm'
    });

    Map<String, dynamic> data = {
      "app_id": "a76b840d-e984-486c-bbbc-099bcb77f55f",
      "include_player_ids": playerIds,
      "data": {"foo": "bar"},
      "headings": {"en": title},
      "contents": {"en": subtitle}
    };

    response = await dio.post(route, options: options, data: data);
    if (response.statusCode == 200) {
      print('berhasil kirim email');
      return true;
    } else {
      print(
          'gagal kirim email, response code : ${response.statusCode}, message : ${response.statusMessage}');
      throw Exception(response.statusCode);
    }
  } catch (error, stacktrace) {
    print("Exception occured: $error stackTrace: $stacktrace");
    return false;
  }
}

// Future<List<String>> parseJsonFromAssets() async {
//   /*
//     22/07/2021 ganti pemanggilan aset melalui file unit_kerja.json yang ada di folder config pada firebase storage
//     */
//   // String jsonStr =
//   //     await rootBundle.loadString('assets/master/unit_kerja.json');
//   // List<String> jsonObj = List.from(json.decode(jsonStr));

//   List<UnitKerja> unitKerjas = await getUni/tKerjas();
//   List<String> jsonObj = unitKerjas.map((e) => e.nama).toList();

//   // Jika admin yang login adalah admin unit, tampilkan hanya list unit tersebut
//   Staff sessionStaff = await loadSession();
//   if (sessionStaff.isAdminUnit) {
//     jsonObj = jsonObj.where((unit) => unit == sessionStaff.unitKerja).toList();
//   }

//   return jsonObj;
// }

extension StringExt on String {
  String showMax(int max) {
    if (this.length > max) {
      return this.substring(0, max) + '...';
    }
    return this;
  }
}

void alert(
    {required BuildContext context,
    String title: 'Perhatian',
    required List<Widget> children}) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          titlePadding: EdgeInsets.fromLTRB(12, 24.0, 24.0, 0.0),
          contentPadding: EdgeInsets.all(12),
          title: Text(title),
          children: children,
        );
      });
}

String formatDate(DateTime date) {
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}

String dateIndo(String date) {
  List<String> dateArr = date.split(', ');
  String hari = dateArr[0], bulanTanggal = dateArr[1], tahun = dateArr[2];
  List<String> bulanTanggalArr = bulanTanggal.split(' ');
  String bulan = bulanTanggalArr[0], tanggal = bulanTanggalArr[1];
  switch (hari) {
    case 'Monday':
      hari = 'Senin';
      break;

    case 'Tuesday':
      hari = 'Selasa';
      break;

    case 'Wednesday':
      hari = 'Rabu';
      break;

    case 'Thursday':
      hari = 'Kamis';
      break;

    case 'Friday':
      hari = 'Jum\'at';
      break;

    case 'Saturday':
      hari = 'Sabtu';
      break;

    case 'Sunday':
      hari = 'Minggu';
      break;
  }

  bulan = (bulan);

  return "$hari, $tanggal $bulan $tahun";
}

String namaBulanIndo(String nama) {
  String bulan = '';
  switch (nama) {
    case 'January':
      bulan = 'Januari';
      break;

    case 'February':
      bulan = 'Februari';
      break;

    case 'March':
      bulan = 'Maret';
      break;

    case 'May':
      bulan = 'Mei';
      break;

    case 'June':
      bulan = 'Juni';
      break;

    case 'July':
      bulan = 'Juli';
      break;

    case 'August':
      bulan = 'Agustus';
      break;

    case 'September':
      bulan = 'September';
      break;

    case 'October':
      bulan = 'Oktober';
      break;

    case 'December':
      bulan = 'Desember';
      break;
  }

  return bulan;
}

String dateOnlyIndo(String date) {
  List<String> dateArr = date.split(', ');
  String hari = dateArr[0], bulanTanggal = dateArr[1], tahun = dateArr[2];
  List<String> bulanTanggalArr = bulanTanggal.split(' ');
  String bulan = bulanTanggalArr[0], tanggal = bulanTanggalArr[1];
  switch (hari) {
    case 'Monday':
      hari = 'Senin';
      break;

    case 'Tuesday':
      hari = 'Selasa';
      break;

    case 'Wednesday':
      hari = 'Rabu';
      break;

    case 'Thursday':
      hari = 'Kamis';
      break;

    case 'Friday':
      hari = 'Jum\'at';
      break;

    case 'Saturday':
      hari = 'Sabtu';
      break;

    case 'Sunday':
      hari = 'Minggu';
      break;
  }

  switch (bulan) {
    case 'January':
      bulan = 'Januari';
      break;

    case 'February':
      bulan = 'Februari';
      break;

    case 'March':
      bulan = 'Maret';
      break;

    case 'May':
      bulan = 'Mei';
      break;

    case 'June':
      bulan = 'Juni';
      break;

    case 'July':
      bulan = 'Juli';
      break;

    case 'August':
      bulan = 'Agustus';
      break;

    case 'September':
      bulan = 'September';
      break;

    case 'October':
      bulan = 'Oktober';
      break;

    case 'December':
      bulan = 'Desember';
      break;
  }

  return "$tanggal $bulan $tahun";
}

void alertAct(
    {required BuildContext context,
    bool barrierDismissible: true,
    String title: 'Perhatian',
    required Widget content,
    required List<Widget> actions}) {
  showDialog(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.fromLTRB(12, 24.0, 24.0, 0.0),
          contentPadding: EdgeInsets.all(12),
          title: Text(title),
          content: content,
          actions: actions,
        );
      });
}

List<DateTime> getDaysInBeteween(DateTime? startDate, DateTime? endDate,
    {RadioDay selectedRadioDay: RadioDay.work_day}) {
  print(selectedRadioDay);
  List<DateTime> days = [];
  if (startDate != null && endDate != null) {
    print(
        'cari selisih hari dari ${DateFormat.yMMMMEEEEd().format(startDate)} hingga ${DateFormat.yMMMMEEEEd().format(endDate)}');
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      if (selectedRadioDay == RadioDay.work_day) {
        // jik hari kerja (bukan tgl merah), masukkan ke list
        if (startDate.add(Duration(days: i)).isWorkingDay()) {
          days.add(startDate.add(Duration(days: i)));
        }
        // jika all day
      } else {
        days.add(startDate.add(Duration(days: i)));
      }
    }
  }
  return days;
}

extension DateTimeExt on DateTime {
  bool isWorkingDay() {
    bool isSeninSdJumat = (weekday >= 1 && weekday <= 5);
    bool isTanggalMerah = false;
    SysConfig.listTanggalMerah().forEach((tgl) {
      if (this.isSameDate(tgl)) isTanggalMerah = true;
    });
    // print('this : ${DateFormat('yyyy-MM-dd').format(this)}');
    // print('isSeninSdJumat : $isSeninSdJumat');
    // print('isTanggalMerah : $isTanggalMerah');
    return (isSeninSdJumat && !isTanggalMerah);
  }

  bool isSameDate(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}
