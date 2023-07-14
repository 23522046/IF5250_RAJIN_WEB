import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:if5250_rajin_apps_web/model/sys_config.dart';
import 'package:if5250_rajin_apps_web/model/unit_kerja.dart';
import 'package:if5250_rajin_apps_web/utils/session.dart';

import '../model/staff.dart';
import 'index.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nipCont = TextEditingController();
  TextEditingController passCont = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueGrey[600],
        body: Builder(
          builder: (context) => Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const CircleAvatar(
                      radius: 100,
                      backgroundImage: AssetImage('assets/images/logo.png'),
                    ),
                    const Text(
                      'RAJIN APPS ADMINISTRATOR',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rekam Jejak Presensi Online',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.teal.shade100,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 150.0,
                      height: 20.0,
                      child: Divider(color: Colors.teal.shade100),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 25.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller: nipCont,
                                decoration: const InputDecoration(
                                  icon: Icon(Icons.person),
                                  hintText: 'Masukkan Username',
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Harus diisi';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                onFieldSubmitted: (value) {
                                  submit();
                                },
                                controller: passCont,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  icon: Icon(Icons.lock),
                                  hintText: 'Masukkan Password',
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Harus diisi';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 16.0,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: MaterialButton(
                                  onPressed: () async {
                                    submit();
                                  },
                                  elevation: 4.0,
                                  minWidth: double.infinity,
                                  height: 48.0,
                                  color: Colors.pinkAccent,
                                  child: const Text(
                                    "LOGIN",
                                    style: TextStyle(
                                      fontFamily: 'SourceSansPro',
                                      color: Colors.white,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        late Map<String, dynamic> staffMap;
        staffMap = signInSuperUser(nipCont.text, passCont.text);
        if (staffMap.isEmpty) {
          final credential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                  email: nipCont.text, password: passCont.text);

          if (credential.user == null) {
            throw ("User is found");
          }

          User user = credential.user!;

          DocumentReference staffRef =
              FirebaseFirestore.instance.collection('staff').doc(user.uid);

          DocumentSnapshot staff = await staffRef.get();

          if (!staff.exists) {
            throw ('Data tidak ditemukan, silahkan cek kembali');
          }

          // print(staff.data());

          staffMap = staff.data() as Map<String, dynamic>;

          DocumentSnapshot unitKerjaSnap =
              await (staffMap['unit_kerja'] as DocumentReference).get();

          UnitKerja unitKerja = UnitKerja.fromJson(
              unitKerjaSnap.data() as Map<String, dynamic>, unitKerjaSnap.id);

          DocumentSnapshot unitKerjaParentSnap = await unitKerja.parent!.get();

          UnitKerja unitKerjaParent = UnitKerja.fromJson(
              unitKerjaParentSnap.data() as Map<String, dynamic>,
              unitKerjaParentSnap.id);

          staffMap['unit_kerja_parent'] = unitKerja.parent;
          staffMap['unit_kerja_parent_name'] = unitKerjaParent.nama;
        }

        createSession(staffMap);

        Staff staffSession = await loadSession();

        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => IndexPage(staffSession: staffSession)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 3), content: Text(e.toString())));
      }
    }
  }
}
