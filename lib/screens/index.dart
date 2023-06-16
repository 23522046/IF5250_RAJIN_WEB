import 'package:flutter/material.dart';
import 'package:if5250_rajin_apps_web/screens/tab/status.dart';

import '../model/staff.dart';
import '../utils/session.dart';
import 'login.dart';
import 'tab/absensi.dart';

class IndexPage extends StatefulWidget {
  Staff sessionStaff;

  IndexPage({required this.sessionStaff});

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  Widget? _selectedTab;
  String _title = 'Laporan Kehadiran';
  String name = 'Memuat...', role = 'Memuat...';
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _selectTab(Widget tab, String title) {
    Navigator.pop(context);
    setState(() {
      _title = title;
      _selectedTab = tab;
    });
  }

  @override
  void initState() {
    _selectedTab = AbsensiTab(scaffoldKey: _scaffoldKey);
    _loadSession();
    super.initState();
  }

  void _loadSession() async {
    Staff s = await loadSession();
    print(s.jenisAkunWeb);
    setState(() {
      name = s.nama ?? '';
      role = (s.isAdminSistem)
          ? '${s.noInduk} - ${s.jenisAkunWeb}'
          : '${s.noInduk} - Administrator Sistem';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: _selectedTab,
      key: _scaffoldKey,
      drawer: Drawer(
          child: ListView(padding: EdgeInsets.zero, children: [
        UserAccountsDrawerHeader(
          accountName: new Text(name),
          accountEmail: new Text(role),
          decoration: new BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/south_america.jpg'),
                fit: BoxFit.cover),
            color: Colors.green,
          ),
          currentAccountPicture: Container(
              width: 190.0,
              height: 190.0,
              decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage("assets/images/dummy-ava.png")))),
        ),
        ListTile(
            leading: Icon(Icons.home),
            title: Text('Utama'),
            onTap: () =>
                _selectTab(AbsensiTab(scaffoldKey: _scaffoldKey), 'Utama')),
        // ListTile(
        //     leading: Icon(Icons.check_circle),
        //     title: Text(
        //       'Laporan Bulanan',
        //       // style: TextStyle(fontWeight: FontWeight.bold)
        //     ),
        //     onTap: () => _selectTab(
        //         LaporananBulananTab(scaffoldKey: _scaffoldKey),
        //         'Laporan Bulanan')),

        /* Sedang dalam pengerjaan */
        // ListTile(
        //     leading: Icon(Icons.document_scanner_rounded),
        //     title: Text(
        //       'Laporan P1',
        //       // style: TextStyle(fontWeight: FontWeight.bold)
        //     ),
        //     onTap: () => _selectTab(LaporananP1Tab(scaffoldKey: _scaffoldKey),
        //         'Laporan P1 Pegawai dan Dosen')),

        // ListTile(
        //     leading: Icon(Icons.calendar_today_sharp),
        //     title: Text('Laporan Uang Makan'),
        //     onTap: () => _selectTab(
        //         UangMakanTab(scaffoldKey: _scaffoldKey), 'Laporan Uang Makan')),
        // if (widget.sessionStaff.isAdminSistem)
        //   ListTile(
        //       leading: Icon(Icons.check_circle),
        //       title: Text('Laporan Tahunan'),
        //       onTap: () => _selectTab(
        //           AbsensiTab(scaffoldKey: _scaffoldKey), 'Laporan Tahunan')),
        ListTile(
            leading: Icon(Icons.assignment),
            title: Text('Permohonan Sakit dan Cuti'),
            onTap: () => _selectTab(StatusTab(scaffoldKey: _scaffoldKey),
                'Permohonan Sakit dan Cuti')),
        // if (widget.sessionStaff.isAdminSistem ||
        //     widget.sessionStaff.isAdminUnit)
        //   ListTile(
        //       leading: Icon(Icons.person_pin),
        //       title: Text('Pegawai & Dosen'),
        //       onTap: () =>
        //           _selectTab(StaffTab(scaffoldKey: _scaffoldKey), 'Pegawai')),
        // if (widget.sessionStaff.isAdminSistem)
        // ListTile(
        //     leading: Icon(Icons.auto_fix_normal),
        //     title: Text('Data Cleansing'),
        //     onTap: () => Navigator.of(context).push(
        //         MaterialPageRoute(builder: (context) => DataCleansingPage()))),
        // if (widget.sessionStaff.isAdminSistem)
        //   ListTile(
        //       leading: Icon(Icons.work, color: Colors.grey),
        //       title: Text('Unit Kerja', style: TextStyle(color: Colors.grey)),
        //       onTap: () {}),
        // if (widget.sessionStaff.isAdminSistem)
        //   ListTile(
        //       leading: Icon(Icons.group_work, color: Colors.grey),
        //       title: Text('Jabatan', style: TextStyle(color: Colors.grey)),
        //       onTap: () {}),
        ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Keluar'),
            onTap: () async {
              await clearSession();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => LoginPage()));
            })
      ])),
    );
  }
}
