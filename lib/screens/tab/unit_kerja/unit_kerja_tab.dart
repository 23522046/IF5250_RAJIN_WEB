import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:if5250_rajin_apps_web/screens/tab/staff/staff_form.dart';
import 'package:if5250_rajin_apps_web/screens/tab/staff/staff_table.dart';
import 'package:if5250_rajin_apps_web/screens/tab/unit_kerja/unit_kerja_form.dart';
import 'package:if5250_rajin_apps_web/widgets/featured_heading.dart';

import '../../../model/staff.dart';
import '../../../model/unit_kerja.dart';
import '../../../utils/session.dart';
import 'unit_kerja_table.dart';

class UnitKerjaTab extends StatefulWidget {
  UnitKerjaTab({super.key, required GlobalKey<ScaffoldState> scaffoldKey});

  @override
  State<UnitKerjaTab> createState() => _UnitKerjaTabState();
}

class _UnitKerjaTabState extends State<UnitKerjaTab> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController noIndukCont = TextEditingController();
  List<UnitKerja> listUnitKerja = <UnitKerja>[];

  void _clearForm() {
    setState(() {
      noIndukCont.text = '';
      listUnitKerja.clear();
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
            await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return UnitKerjaForm(
                      unitKerja: null, staffSession: staffSession);
                });

            actionReloadData(staffSession.unitKerjaParent!.id);
          }),
      body: ListView(
        shrinkWrap: true,
        children: [
          FeaturedHeading(
            title: 'Daftar Unit Kerja',
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
          if (listUnitKerja.isNotEmpty)
            UnitKerjaTable(
              reloadData: () =>
                  actionReloadData(staffSession.unitKerjaParent!.id),
              unitKerjas: listUnitKerja,
              staffSession: staffSession,
            )
        ],
      ),
    );
  }

  Flexible renderEditText(TextEditingController controller, String labelText) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            icon: const Icon(Icons.format_list_numbered),
            labelText: labelText,
          ),
          validator: (value) {
            if (value != null) {
              if (value.length > 0 && value.length < 5) {
                return "Minimal 5 karakter";
              }
            }

            return null;
          },
        ),
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
    QuerySnapshot s = await FirebaseFirestore.instance
        .collection(UnitKerja.collectionName)
        .where('parent',
            isEqualTo: FirebaseFirestore.instance
                .collection(UnitKerja.collectionName)
                .doc(unitKerjaParentId))
        .get();

    setState(() {
      listUnitKerja = s.docs
          .map(
              (e) => UnitKerja.fromJson(e.data() as Map<String, dynamic>, e.id))
          .toList();
    });
  }
}
