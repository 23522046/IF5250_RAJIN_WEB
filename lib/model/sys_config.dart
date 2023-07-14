import 'package:if5250_rajin_apps_web/model/staff.dart';
import 'package:if5250_rajin_apps_web/utils/util.dart';

import 'jam_kerja.dart';
import 'presensi.dart';

Map<String, dynamic> signInSuperUser(String email, String password) {
  if (email == 'root' && password == 'root') {
    Map<String, dynamic> superUser = {
      'UID': null,
      'is_aktif': true,
      'is_super_user': true,
      'nama': 'Super User',
      'no_induk': '01',
      'unit_kerja_parent_name': 'RAJIN APPS SU'
    };
    return superUser;
  }
  return {};
}

MasterJamKerja getMasterJamkerja(
    DateTime dateTime, Presensi? presensi, List<JamKerja> jamKerjas) {
  List<MasterJamKerja> listJamKerja = jamKerjas.map((j) {
    var jamMasuk = j.masuk.split(':');
    var jamPulang = j.pulang.split(':');
    return MasterJamKerja(
        weekday: j.weekday,
        jamMasuk: DateTime(
            dateTime.year,
            dateTime.month,
            dateTime.day,
            int.parse(jamMasuk[0]),
            int.parse(jamMasuk[1]),
            int.parse(jamMasuk[2])),
        jamPulang: DateTime(
            dateTime.year,
            dateTime.month,
            dateTime.day,
            int.parse(jamPulang[0]),
            int.parse(jamPulang[1]),
            int.parse(jamPulang[2])));
  }).toList();

  return listJamKerja.firstWhere(
      (jamKerja) =>
          jamKerja.weekday == dateTime.weekday && dateTime.isWorkingDay(),
      orElse: () => MasterJamKerja(
          weekday: dateTime.weekday,
          jamMasuk:
              DateTime(dateTime.year, dateTime.month, dateTime.day, 07, 59, 00),
          jamPulang: DateTime(
              dateTime.year, dateTime.month, dateTime.day, 16, 00, 00)));
}

class SysConfig {
  //setup tanggal merah
  static List<dynamic> listTanggalMerah() {
    final List<dynamic> list = [
      DateTime(2021, 01, 01),
      DateTime(2021, 02, 12),
      DateTime(2021, 03, 11),
      // DateTime(2021, 03, 12),
      DateTime(2021, 03, 14),
      DateTime(2021, 04, 02),
      DateTime(2021, 05, 12),
      DateTime(2021, 05, 13),
      DateTime(2021, 05, 14),
      DateTime(2021, 05, 26),
      DateTime(2021, 06, 01),
      DateTime(2021, 07, 20),
      DateTime(2021, 08, 11),
      DateTime(2021, 08, 17),
      DateTime(2021, 10, 20),
      // DateTime(2021, 12, 24),
      // DateTime(2021, 12, 27),
      DateTime(2022, 02, 01),
      DateTime(2022, 02, 28),
      DateTime(2022, 03, 03),
      DateTime(2022, 04, 15),
      DateTime(2022, 04, 29),
      DateTime(2022, 05, 02),
      DateTime(2022, 05, 03),
      DateTime(2022, 05, 04),
      DateTime(2022, 05, 05),
      DateTime(2022, 05, 06),
      DateTime(2022, 05, 16),
      DateTime(2022, 05, 26),
      DateTime(2022, 06, 01),
      DateTime(2022, 08, 17),
    ];

    return list;
  }
}

class MasterJamKerja {
  final int weekday;
  DateTime jamMasuk, jamPulang;

  MasterJamKerja(
      {required this.weekday, required this.jamMasuk, required this.jamPulang});
}
