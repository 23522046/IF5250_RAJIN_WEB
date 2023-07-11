import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:if5250_rajin_apps_web/model/jam_kerja.dart';
import 'package:if5250_rajin_apps_web/model/unit_kerja.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/staff.dart';

const String IS_LOGIN = "is_login";
const String NO_INDUK = "no_induk";
const String NAMA = "nama";
const String UNIT_KERJA_ID = "unit_kerja";
const String UNIT_KERJA_PARENT_ID = "unit_kerja_parent";
const String UNIT_KERJA_PARENT_NAME = "unit_kerja_parent_name";
const String JAM_KERJA = "jam_kerja";

Future<bool> createSession(Map<String, dynamic> staff) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(IS_LOGIN, true);
  prefs.setString(NO_INDUK, staff['no_induk']);
  prefs.setString(NAMA, staff['nama']);
  prefs.setString(UNIT_KERJA_ID, (staff['unit_kerja'] as DocumentReference).id);
  prefs.setString(UNIT_KERJA_PARENT_ID,
      (staff['unit_kerja_parent'] as DocumentReference).id);
  prefs.setString(UNIT_KERJA_PARENT_NAME, staff['unit_kerja_parent_name']);

  List<JamKerja> jamKerja = (staff['jam_kerja'] as List<dynamic>)
      .map((j) => JamKerja.fromJson(j))
      .toList();

  prefs.setStringList(JAM_KERJA,
      jamKerja.map((j) => '${j.weekday}#${j.masuk}#${j.pulang}').toList());

  return true;
}

Future<Staff> loadSession() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('unit_kerja')
      .doc(prefs.getString(UNIT_KERJA_PARENT_ID)!)
      .get();

  UnitKerja unitKerjaParent =
      UnitKerja.fromJson(snapshot.data() as Map<String, dynamic>, snapshot.id);

  Staff s = Staff(
      noInduk: prefs.getString(NO_INDUK),
      nama: prefs.getString(NAMA),
      unitKerjaParentName: prefs.getString(UNIT_KERJA_PARENT_NAME),
      unitKerja: FirebaseFirestore.instance
          .collection('unit_kerja')
          .doc(prefs.getString(UNIT_KERJA_ID)!),
      unitKerjaParent: FirebaseFirestore.instance
          .collection('unit_kerja')
          .doc(prefs.getString(UNIT_KERJA_PARENT_ID)!),
      unitKerjaParentCol: unitKerjaParent);

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
