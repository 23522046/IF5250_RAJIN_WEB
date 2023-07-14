import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:if5250_rajin_apps_web/model/jam_kerja.dart';
import 'package:if5250_rajin_apps_web/utils/util.dart';

import '../../../model/staff.dart';
import '../../../model/unit_kerja.dart';
import '../../../utils/session.dart';
import '../../../widgets/featured_heading.dart';
import 'jam_kerja_table.dart';

class JamKerjaTab extends StatefulWidget {
  JamKerjaTab({super.key, required GlobalKey<ScaffoldState> scaffoldKey});

  @override
  State<JamKerjaTab> createState() => _JamKerjaTabState();
}

class _JamKerjaTabState extends State<JamKerjaTab> {
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> listWeekdayCont = [];
  List<TextEditingController> listJamMasukCont = [];
  List<TextEditingController> listJamPulangCont = [];
  List<JamKerja> listJamKerja = [];

  void _clearForm() {
    setState(() {
      listWeekdayCont.clear();
      listJamMasukCont.clear();
      listJamPulangCont.clear();
      listJamKerja.clear();
    });
  }

  @override
  void initState() {
    loadSession().then((staffSession) {
      actionReloadData(staffSession.unitKerjaParent!.id);
    });
    super.initState();
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            backgroundColor: Colors.blue,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Hari'),
            onPressed: () => addRowField(),
          ),
          const SizedBox(height: 10),
          if (listWeekdayCont.isNotEmpty)
            FloatingActionButton.extended(
              icon: const Icon(Icons.check),
              label: const Text('Simpan Data'),
              onPressed: () => updateRecord(staffSession.unitKerjaParent!.id)
                  .then((value) =>
                      actionReloadData(staffSession.unitKerjaParent!.id)),
            )
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          FeaturedHeading(
            title: 'Jam Kerja',
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
          if (listWeekdayCont.isNotEmpty)
            JamKerjaTable(
              reloadData: () =>
                  actionReloadData(staffSession.unitKerjaParent!.id),
              jamKerja: listJamKerja,
              staffSession: staffSession,
              listWeekdayCont: listWeekdayCont,
              listJamMasukCont: listJamMasukCont,
              listJamPulangCont: listJamPulangCont,
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
                          if (_formKey.currentState!.validate()) {
                            actionReloadData(staffSession.unitKerjaParent!.id);
                          }
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
    _clearForm();
    DocumentSnapshot s = await FirebaseFirestore.instance
        .collection(UnitKerja.collectionName)
        .doc(unitKerjaParentId)
        .get();

    setState(() {
      UnitKerja unitKerja =
          UnitKerja.fromJson(s.data() as Map<String, dynamic>, s.id);
      listJamKerja = unitKerja.jamKerja ?? [];
      listJamKerja.sort((a, b) => a.weekday.compareTo(b.weekday));

      listJamKerja.asMap().forEach((index, jamKerja) {
        listWeekdayCont.add(TextEditingController());
        listJamMasukCont.add(TextEditingController());
        listJamPulangCont.add(TextEditingController());
      });
    });
    print('actionReloadData() invoked');
  }

  void addRowField() {
    if (listWeekdayCont.length >= 7) {
      return alert(context: context, children: [
        const Text(
            'Sudah mencapai jumlah maksimal hari kerja (7) dalam seminggu')
      ]);
    }
    setState(() {
      listWeekdayCont.add(TextEditingController());
      listJamMasukCont.add(TextEditingController());
      listJamPulangCont.add(TextEditingController());
    });
  }

  Future<bool> updateRecord(String unitKerjaParentId) async {
    try {
      DocumentReference ref = FirebaseFirestore.instance
          .collection(UnitKerja.collectionName)
          .doc(unitKerjaParentId);

      List<JamKerja> listJamKerja = [];

      listWeekdayCont.asMap().forEach((index, value) {
        JamKerja jamKerja = JamKerja(
            weekday: int.parse(listWeekdayCont[index].text),
            masuk: listJamMasukCont[index].text,
            pulang: listJamPulangCont[index].text);

        listJamKerja.add(jamKerja);
      });

      await ref.update({
        'jam_kerja': listJamKerja.map((b) => b.toJson()).toList(),
        'time_update': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print(e.toString());
    }
    return false;
  }
}
