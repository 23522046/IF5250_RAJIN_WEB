import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:if5250_rajin_apps_web/model/staff.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/index.dart';
import 'screens/login.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<Staff?> _loadSession(context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    DocumentReference staffRef =
        FirebaseFirestore.instance.collection('staff').doc(user.uid);

    DocumentSnapshot staff = await staffRef.get();

    if (!staff.exists) {
      throw ('Data user tidak ditemukan, silahkan cek kembali');
    }

    Staff _staff = Staff.fromJson(staff.data() as Map<String, dynamic>);
    return _staff;
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {}
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.purple),
      home:
          //  LoginPage()
          FutureBuilder<Staff?>(
        future: _loadSession(context),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
                body: SafeArea(
                    child:
                        Container(child: Text('Error.. : ${snapshot.error}'))));
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return IndexPage();
            }
            return LoginPage();
          }

          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 120,
                      backgroundImage: AssetImage('assets/images/logo.png'),
                    ),
                    const Text('Loading...',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25)),
                    const SizedBox(height: 20),
                    const CircularProgressIndicator()
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
