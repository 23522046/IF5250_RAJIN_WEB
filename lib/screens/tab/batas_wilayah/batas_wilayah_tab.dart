import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:if5250_rajin_apps_web/model/batas_wilayah.dart';
import 'package:if5250_rajin_apps_web/screens/tab/batas_wilayah/form/batas_wilayah_set_polygon.dart';
import 'package:if5250_rajin_apps_web/screens/tab/staff/staff_form.dart';
import 'package:if5250_rajin_apps_web/screens/tab/staff/staff_table.dart';
import 'package:if5250_rajin_apps_web/widgets/featured_heading.dart';

import '../../../model/staff.dart';
import '../../../model/unit_kerja.dart';
import '../../../utils/session.dart';
import 'batas_wilayah_table.dart';

class BatasWilayahTab extends StatefulWidget {
  BatasWilayahTab({super.key, required GlobalKey<ScaffoldState> scaffoldKey});

  @override
  State<BatasWilayahTab> createState() => _BatasWilayahTabState();
}

class _BatasWilayahTabState extends State<BatasWilayahTab> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController noIndukCont = TextEditingController();
  List<BatasWilayah> listBatasWilayah = <BatasWilayah>[];

  void _clearForm() {
    setState(() {
      noIndukCont.text = '';
      listBatasWilayah.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadSession(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("${snapshot.error}");
        } else if (snapshot.connectionState == ConnectionState.done) {
          return (snapshot.hasData)
              ? renderBody(context, snapshot.data!)
              : const Text('loadSession() result is null');
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget renderBody(BuildContext context, Staff staffSession) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          bool? res = await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  BatasWilayahSetPolygon(staffSession: staffSession))) as bool;
          if (res == true) actionReloadData(staffSession.unitKerjaParent!.id);
        },
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          FeaturedHeading(
            title: 'Batas Wilayah Kerja',
            screenSize: screenSize,
            subtitle: '',
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: screenSize.width / 15),
              child: const Text(
                'Gunakan filter untuk mencari unit kerja',
                style: TextStyle(fontStyle: FontStyle.italic),
              )),
          renderSearchFilter(screenSize, staffSession),
          if (listBatasWilayah.isNotEmpty)
            BatasWilayahTable(
              reloadData: () =>
                  actionReloadData(staffSession.unitKerjaParent!.id),
              batasWilayah: listBatasWilayah,
              staffSession: staffSession,
            )
        ],
      ),
    );
  }

  renderSearchFilter(Size screenSize, Staff staffSession) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width / 15),
      child: SizedBox(
        width: screenSize.width,
        child: Card(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Row(
                    children: [
                      Expanded(
                          child: MaterialButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate())
                            actionReloadData(staffSession.unitKerjaParent!.id);
                        },
                        color: Colors.pinkAccent,
                        child: const Text(
                          'CARI',
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                      const SizedBox(width: 5),
                      Expanded(
                          child: TextButton(
                        onPressed: () => _clearForm(),
                        child: const Text('RESET'),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }

  void actionReloadData(String unitKerjaParentId) async {
    DocumentSnapshot s = await FirebaseFirestore.instance
        .collection(UnitKerja.collectionName)
        .doc(unitKerjaParentId)
        .get();

    setState(() {
      UnitKerja unitKerja =
          UnitKerja.fromJson(s.data() as Map<String, dynamic>, s.id);
      listBatasWilayah = unitKerja.batasWilayah ?? [];
    });
    print('actionReloadData() invoked');
  }
}
