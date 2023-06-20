import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/staff.dart';

const String IS_LOGIN = "is_login";
const String NO_INDUK = "no_induk";
const String NAMA = "nama";
const String UNIT_KERJA_ID = "unit_kerja";
const String UNIT_KERJA_PARENT_ID = "unit_kerja_parent";

Future<bool> createSession(Map<String, dynamic> staff) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(IS_LOGIN, true);
  prefs.setString(NO_INDUK, staff['no_induk']);
  prefs.setString(NAMA, staff['nama']);
  prefs.setString(UNIT_KERJA_ID, (staff['unit_kerja'] as DocumentReference).id);
  prefs.setString(UNIT_KERJA_PARENT_ID,
      (staff['unit_kerja_parent'] as DocumentReference).id);
  return true;
}

Future<Staff> loadSession() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Staff s = Staff(
      noInduk: prefs.getString(NO_INDUK),
      nama: prefs.getString(NAMA),
      unitKerja: FirebaseFirestore.instance
          .collection('unit_kerja')
          .doc(prefs.getString(UNIT_KERJA_ID)!),
      unitKerjaParent: FirebaseFirestore.instance
          .collection('unit_kerja')
          .doc(prefs.getString(UNIT_KERJA_PARENT_ID)!));
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
