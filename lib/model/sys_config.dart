import 'package:if5250_rajin_apps_web/utils/util.dart';

import 'presensi.dart';

MasterJamKerja getMasterJamkerja(DateTime dateTime, Presensi? presensi) {
  return SysConfig.listJamKerja(presensi?.timeCreate.toDate()).firstWhere(
      (jamKerja) =>
          jamKerja.weekday == dateTime.weekday && dateTime.isWorkingDay()
      // ,orElse: () => null
      );
}

class SysConfig {
  static int uangMakanNonPns = 20000;

  static List<String> listUntrackedUser() {
    return ['root', '130020002', 'presensia.root'];
  }

  static List<MasterJamKerja> listJamKerja(DateTime? dateTime) {
    dateTime = dateTime ?? DateTime.now();

    // jam kerja hari normal mulai 2 agustus 2022
    List<MasterJamKerja> modeE = [
      MasterJamKerja(
          weekday: 1,
          jamMasuk:
              DateTime(dateTime.year, dateTime.month, dateTime.day, 7, 59, 00),
          jamPulang:
              DateTime(dateTime.year, dateTime.month, dateTime.day, 16, 00)),
      MasterJamKerja(
          weekday: 2,
          jamMasuk:
              DateTime(dateTime.year, dateTime.month, dateTime.day, 7, 59, 00),
          jamPulang:
              DateTime(dateTime.year, dateTime.month, dateTime.day, 16, 00)),
      MasterJamKerja(
          weekday: 3,
          jamMasuk:
              DateTime(dateTime.year, dateTime.month, dateTime.day, 7, 59, 00),
          jamPulang:
              DateTime(dateTime.year, dateTime.month, dateTime.day, 16, 00)),
      MasterJamKerja(
          weekday: 4,
          jamMasuk:
              DateTime(dateTime.year, dateTime.month, dateTime.day, 7, 59, 00),
          jamPulang:
              DateTime(dateTime.year, dateTime.month, dateTime.day, 16, 00)),
      MasterJamKerja(
          weekday: 5,
          jamMasuk:
              DateTime(dateTime.year, dateTime.month, dateTime.day, 7, 59, 00),
          jamPulang:
              DateTime(dateTime.year, dateTime.month, dateTime.day, 16, 30)),
    ];

    // setup jam kerja
    List<MasterJamKerja> jamKerjas;
    jamKerjas = modeE; // dari setelah 1 Agustus 2022

    return jamKerjas;
  }

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
