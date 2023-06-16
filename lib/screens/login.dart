import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import '../model/staff.dart';
import '../utils/session.dart';
import 'index.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nipCont = new TextEditingController();
  TextEditingController passCont = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueGrey[600],
        body: Builder(
          builder: (context) => Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Visibility(
                      visible: true,
                      child: CircleAvatar(
                        radius: 100,
                        backgroundImage: AssetImage('assets/images/logo.png'),
                      ),
                    ),
                    Text(
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
                      margin: EdgeInsets.symmetric(
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
                              SizedBox(
                                height: 16.0,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: new MaterialButton(
                                  child: Text(
                                    "LOGIN",
                                    style: TextStyle(
                                      fontFamily: 'SourceSansPro',
                                      color: Colors.white,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  onPressed: () async {
                                    submit();
                                  },
                                  elevation: 4.0,
                                  minWidth: double.infinity,
                                  height: 48.0,
                                  color: Colors.pinkAccent,
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
// process data
        String passHash = sha1.convert(utf8.encode(passCont.text)).toString();
        // DocumentReference staffRef =
        //     FirebaseFirestore.instance.collection('staff').doc(nipCont.text);
        DocumentReference staffRef = FirebaseFirestore.instance
            .collection('staff')
            .doc('89WaRxxcffWzQFPGwnBRjJJ2QdG2');

        DocumentSnapshot staff = await staffRef.get();

        if (!staff.exists) {
          throw ('NIP/NIK tidak ditemukan, silahkan cek kembali');
        }

        print(staff.data());

        Staff _staff = Staff.fromJson(staff.data() as Map<String, dynamic>);

        createSession(staff.data() as Map<String, dynamic>);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => IndexPage(
                  sessionStaff:
                      Staff.fromJson(staff.data() as Map<String, dynamic>),
                )));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 3), content: Text(e.toString())));
      }
    }
  }
}