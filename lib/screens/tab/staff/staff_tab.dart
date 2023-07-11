import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:if5250_rajin_apps_web/screens/tab/staff/staff_form.dart';
import 'package:if5250_rajin_apps_web/screens/tab/staff/staff_table.dart';
import 'package:if5250_rajin_apps_web/widgets/featured_heading.dart';

import '../../../model/staff.dart';
import '../../../model/unit_kerja.dart';
import '../../../utils/session.dart';

class StaffTab extends StatefulWidget {
  StaffTab({super.key, required GlobalKey<ScaffoldState> scaffoldKey});

  @override
  State<StaffTab> createState() => _StaffTabState();
}

class _StaffTabState extends State<StaffTab> {
  final _formKey = GlobalKey<FormState>();
  UnitKerja? selectedUnitKerja;
  TextEditingController noIndukCont = TextEditingController();
  List<Staff> listStaff = <Staff>[];

  void _clearForm() {
    setState(() {
      noIndukCont.text = '';
      selectedUnitKerja = null;
      listStaff.clear();
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
      body: ListView(
        shrinkWrap: true,
        children: [
          FeaturedHeading(
            title: 'Daftar Pegawai',
            screenSize: screenSize,
            subtitle: '',
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: screenSize.width / 15),
              child: const Text(
                'Gunakan filter untuk mencari pegawai',
                style: TextStyle(fontStyle: FontStyle.italic),
              )),
          renderSearchFilter(screenSize, staffSession),
          if (listStaff.isNotEmpty && selectedUnitKerja != null)
            StaffTable(
              reloadData: () => actionReloadData(selectedUnitKerja!.idDoc),
              staffs: listStaff,
              selectedUnitKerja: selectedUnitKerja!,
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

  Widget _dropDownField(
      String label, UnitKerja? newValue, String idParentUnitKerja) {
    return FutureBuilder(
      // future: parseJsonFromAssets(),
      future: FirebaseFirestore.instance
          .collection('unit_kerja')
          .where('parent',
              isEqualTo: FirebaseFirestore.instance
                  .collection('unit_kerja')
                  .doc(idParentUnitKerja))
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error : ${snapshot.error}");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          if (!snapshot.hasData) return const Text('Tidak ada data');
          List<UnitKerja> _listUnitKerja = snapshot.data!.docs
              .map((d) => UnitKerja.fromJson(d.data(), d.id))
              .toList();

          return DropdownButtonFormField(
            // TODO: ini kalo diaktifkan error duplikat items di dropdown tapi belum tahu kenapa?
            // value: newValue,
            decoration:
                InputDecoration(labelText: label, icon: Icon(Icons.work)),
            validator: (value) {
              // print('value dropdown : $value');
              if (noIndukCont.text.isEmpty && value == null) {
                return "Wajib dipilih";
              }
              return null;
            },
            items: _listUnitKerja.map((value) {
              return DropdownMenuItem(child: Text(value.nama!), value: value);
            }).toList(),
            onChanged: (value) {
              // print('terpilih dropdown $label : $value');
              selectedUnitKerja = value;
            },
          );
        }

        return const LinearProgressIndicator();
      },
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
                Row(
                  children: [
                    renderEditText(noIndukCont, 'Cari berdasarkan Nomor Induk'),
                    const SizedBox(width: 10),
                    Flexible(
                        child: _dropDownField('Unit Kerja', selectedUnitKerja,
                            staffSession.unitKerjaParent!.id)),
                  ],
                ),
                Center(
                  child: Row(
                    children: [
                      Expanded(
                          child: MaterialButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            actionReloadData(selectedUnitKerja!.idDoc!);
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

  void actionReloadData(String selectedUnitKerjaId) async {
    QuerySnapshot s = await FirebaseFirestore.instance
        .collection(Staff.collectionName)
        .where('unit_kerja',
            isEqualTo: FirebaseFirestore.instance
                .collection('unit_kerja')
                .doc(selectedUnitKerjaId))
        .get();

    setState(() {
      listStaff = s.docs
          .map((e) => Staff.fromJson(e.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
