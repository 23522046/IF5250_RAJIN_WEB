import 'package:shared_preferences/shared_preferences.dart';

import '../model/staff.dart';

const String IS_LOGIN = "is_login";
const String NO_INDUK = "no_induk";
const String NAMA = "nama";
const String UNIT_KERJA = "unit_kerja";
const String EMAIL = "email";
const String HP = "hp";
const String JABATAN_STRUKTURAL = "jabatan_struktural";
const String ROLE = 'role';

Future createSession(Map<String, dynamic> staff) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(IS_LOGIN, true);
  prefs.setString(NO_INDUK, staff['no_induk']);
  prefs.setString(NAMA, staff['nama']);
  if (staff.containsKey('unit_kerja'))
    prefs.setString(UNIT_KERJA, staff['unit_kerja']);
  if (staff.containsKey('email')) prefs.setString(EMAIL, staff['email']);
  if (staff.containsKey('hp')) prefs.setString(HP, staff['hp']);
  if (staff.containsKey('jabatan_struktural'))
    prefs.setString(JABATAN_STRUKTURAL, staff['jabatan_struktural']);
  prefs.setString(ROLE, staff['jenis_akun_web']);
  return true;
}

Future<Staff> loadSession() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Staff s = Staff(
      noInduk: prefs.getString(NO_INDUK),
      nama: prefs.getString(NAMA),
      unitKerja: prefs.getString(UNIT_KERJA),
      email: prefs.getString(EMAIL),
      hp: prefs.getString(HP),
      jenisAkunWeb: prefs.getString(ROLE));
  return s;
}

Future clearSession() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
  return true;
}

Future getIdStaff() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(NO_INDUK);
}
