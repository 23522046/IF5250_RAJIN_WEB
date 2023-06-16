import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<SharedPreferences> _loadSession(context) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.green), home: LoginPage()
        // FutureBuilder<SharedPreferences>(
        //   future: _loadSession(context),
        //   builder: (context, snapshot) {
        //     switch (snapshot.connectionState) {
        //       case ConnectionState.active:
        //       case ConnectionState.waiting:
        //         return Scaffold(
        //           body: Center(
        //             child: Padding(
        //               padding: const EdgeInsets.all(16.0),
        //               child: Column(
        //                 children: [
        //                   SizedBox(
        //                       height: 200,
        //                       child: Image.asset('assets/images/logo.png')),
        //                   Text('PRESENSIA',
        //                       style: TextStyle(
        //                           fontWeight: FontWeight.bold, fontSize: 25)),
        //                   SizedBox(height: 20),
        //                   LinearProgressIndicator()
        //                 ],
        //               ),
        //             ),
        //           ),
        //         );
        //       case ConnectionState.done:
        //         if (snapshot.hasData) {
        //           bool isLogin = snapshot.data.getBool(IS_LOGIN) ?? false;
        //           if (isLogin) {
        //             Staff s = Staff(
        //                 noInduk: snapshot.data.getString(NO_INDUK),
        //                 nama: snapshot.data.getString(NAMA),
        //                 unitKerja: snapshot.data.getString(UNIT_KERJA),
        //                 email: snapshot.data.getString(EMAIL),
        //                 hp: snapshot.data.getString(HP),
        //                 jenisAkunWeb: snapshot.data.getString(ROLE));
        //             return IndexPage(sessionStaff: s);
        //           }
        //           return LoginPage();
        //         } else {
        //           return Scaffold(
        //               body: SafeArea(
        //                   child: Container(
        //                       child: Text('Error.. : ${snapshot.error}'))));
        //         }
        //     }
        //   },
        // ),
        );
  }
}
