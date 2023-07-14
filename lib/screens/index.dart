import 'package:flutter/material.dart';
import 'package:if5250_rajin_apps_web/screens/tab/batas_wilayah/batas_wilayah_tab.dart';
import 'package:if5250_rajin_apps_web/screens/tab/jam_kerja/jam_kerja_tab.dart';
import 'package:if5250_rajin_apps_web/screens/tab/unit_kerja/unit_kerja_tab.dart';
import 'package:if5250_rajin_apps_web/utils/session.dart';
import 'package:if5250_rajin_apps_web/utils/util.dart';

import '../model/staff.dart';
import 'login.dart';
import 'tab/absensi/absensi.dart';
import 'tab/approval/approval_tab.dart';
import 'tab/organisasi/organisasi_tab.dart';
import 'tab/staff/staff_tab.dart';

class IndexPage extends StatefulWidget {
  Staff staffSession;

  IndexPage({required this.staffSession});

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  Widget? _selectedTab;
  String _title = 'Laporan Kehadiran',
      _nama = 'Loading...',
      _role = 'Loading...',
      _kodeBergabung = 'Loading...';

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
    _selectedTab = (isLoggedInAsSuperUser())
        ? OrganisasiTab(scaffoldKey: _scaffoldKey)
        : AbsensiTab(scaffoldKey: _scaffoldKey);
    _nama = widget.staffSession.nama!;
    _role = '${widget.staffSession.unitKerjaParentName}';
    _kodeBergabung = widget.staffSession.unitKerjaParent?.id ?? '-';
    super.initState();
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
          accountName: Text(_nama),
          accountEmail: Text(_role),
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/south_america.jpg'),
                fit: BoxFit.cover),
            color: Colors.green,
          ),
          currentAccountPicture: Container(
              width: 190.0,
              height: 190.0,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage("assets/images/dummy-ava.png")))),
        ),
        if (!isLoggedInAsSuperUser())
          ListTile(
              leading: Icon(Icons.home),
              title: Text('Utama'),
              onTap: () =>
                  _selectTab(AbsensiTab(scaffoldKey: _scaffoldKey), 'Utama')),
        if (!isLoggedInAsSuperUser())
          ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Approval Cuti dan Sakit'),
              onTap: () => _selectTab(ApprovalTab(scaffoldKey: _scaffoldKey),
                  'Permohonan Sakit dan Cuti')),
        if (!isLoggedInAsSuperUser())
          ListTile(
              leading: Icon(Icons.person_pin),
              title: Text('Daftar Pegawai'),
              onTap: () => _selectTab(
                  StaffTab(scaffoldKey: _scaffoldKey), 'Daftar Pegawai')),
        if (!isLoggedInAsSuperUser())
          ListTile(
              leading: Icon(Icons.work),
              title: Text('Kelola Unit Kerja'),
              onTap: () => _selectTab(UnitKerjaTab(scaffoldKey: _scaffoldKey),
                  'Daftar Unit Kerja')),
        if (!isLoggedInAsSuperUser())
          ListTile(
              leading: Icon(Icons.location_city),
              title: Text('Batas Wilayah Kerja'),
              onTap: () => _selectTab(
                  BatasWilayahTab(scaffoldKey: _scaffoldKey),
                  'Batas Wilayah Kerja')),
        if (!isLoggedInAsSuperUser())
          ListTile(
              leading: Icon(Icons.lock_clock),
              title: Text('Jam Kerja'),
              onTap: () => _selectTab(JamKerjaTab(scaffoldKey: _scaffoldKey),
                  'Pengaturan Jam Kerja')),
        if (!isLoggedInAsSuperUser())
          ListTile(
              leading: Icon(Icons.key),
              title: Text('Tampilkan Kode Bergabung'),
              onTap: () {
                alert(context: context, title: 'Kode Bergabung', children: [
                  Text('Gunakan Kode Berikut Untuk Bergabung ke $_role : ',
                      style: const TextStyle(fontStyle: FontStyle.italic)),
                  const SizedBox(height: 8),
                  Text(
                    _kodeBergabung,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  )
                ]);
              }),
        if (isLoggedInAsSuperUser())
          ListTile(
              leading: Icon(Icons.people),
              title: const Text('Kelola Instansi Client'),
              onTap: () => _selectTab(OrganisasiTab(scaffoldKey: _scaffoldKey),
                  'Daftar Instansi Perusahaan')),
        ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Keluar'),
            onTap: () async {
              clearSession();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => LoginPage()));
            })
      ])),
    );
  }

  bool isLoggedInAsSuperUser() => widget.staffSession.isSuperUser ?? false;
}
