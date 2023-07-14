import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:if5250_rajin_apps_web/model/unit_kerja.dart';
import 'package:if5250_rajin_apps_web/utils/session.dart';

import '../../../model/pengajuan.dart';
import '../../../model/staff.dart';
import '../../../model/staff_presensi.dart';
import '../../../utils/util.dart';
import '../../../widgets/featured_heading.dart';
import 'approval_table.dart';

GlobalKey<ApprovalTableState> globalKey = GlobalKey();

class ApprovalTab extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  ApprovalTab({required this.scaffoldKey});
  @override
  _ApprovalTabState createState() => _ApprovalTabState();
}

class _ApprovalTabState extends State<ApprovalTab> {
  final _formKey = GlobalKey<FormState>();

  UnitKerja? selectedUnitKerja;
  RadioDay selectedRadioDay = RadioDay.work_day;

  TextEditingController noIndukCont = TextEditingController();
  TextEditingController namaCont = TextEditingController();

  DateTime now = DateTime.now();
  TextEditingController dateTxtContFrom = TextEditingController();
  TextEditingController dateTxtContTo = TextEditingController();
  DateTime? startDate, endDate;
  List<Staff> listStaff = <Staff>[];
  List<String> listNoInduk = <String>[];
  List<Pengajuan> pengajuans = [];

  void _clearForm() {
    setState(() {
      noIndukCont.text = '';
      namaCont.text = '';
      selectedUnitKerja = null;
      dateTxtContFrom.text = '';
      dateTxtContTo.text = '';
      listStaff.clear();
      listNoInduk.clear();
    });
  }

  Widget _dropDownField(
      String label, UnitKerja? newValue, UnitKerja unitKerjaParent) {
    return FutureBuilder(
      // future: parseJsonFromAssets(),
      future: FirebaseFirestore.instance
          .collection('unit_kerja')
          .where('parent',
              isEqualTo: FirebaseFirestore.instance
                  .collection('unit_kerja')
                  .doc(unitKerjaParent.idDoc))
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
              selectedUnitKerja!.unitKerjaParentCol = unitKerjaParent;
            },
          );
        }

        return const LinearProgressIndicator();
      },
    );
  }

  Future<Null> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != now) {
      now = picked;
      if (isFrom) {
        dateTxtContFrom.text = formatDate(now);
        startDate = now;
        dateTxtContTo.text = dateTxtContFrom.text;
        endDate = now;
      } else {
        dateTxtContTo.text = formatDate(now);
        endDate = now;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
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
      ),
    );
  }

  Widget renderBody(BuildContext context, Staff staffSession) {
    var screenSize = MediaQuery.of(context).size;
    return ListView(
      shrinkWrap: true,
      children: [
        FeaturedHeading(
          title: 'Permohonan Sakit dan Cuti',
          screenSize: screenSize,
          subtitle: '',
        ),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width / 15),
            child: const Text(
              'Gunakan filter untuk mencari presensi',
              style: TextStyle(fontStyle: FontStyle.italic),
            )),
        renderSearchFilter(screenSize, staffSession),
        if (pengajuans.isNotEmpty)
          ApprovalTable(
              unitKerja: selectedUnitKerja!,
              pengajuans: pengajuans,
              selectedRadioDay: selectedRadioDay,
              key: globalKey)
      ],
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

  Flexible renderDatePicker(BuildContext context,
      TextEditingController controller, String labelText) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: TextFormField(
          readOnly: true,
          keyboardType: TextInputType.datetime,
          controller: controller,
          validator: (value) {
            if (value!.isEmpty) {
              return "Wajib diisi";
            }
          },
          decoration: InputDecoration(
            icon: const Icon(Icons.date_range),
            labelText: labelText,
            hintText: 'Cari',
          ),
          onTap: () => _selectDate(
              context, (controller == dateTxtContFrom) ? true : false),
        ),
      ),
    );
  }

  Widget renderRadioFilterHari() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 40),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: RadioListTile(
            title: const Text('Hari Kerja'),
            value: RadioDay.work_day,
            onChanged: (val) {
              setState(() {
                selectedRadioDay = val!;
              });
            },
            groupValue: selectedRadioDay,
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: RadioListTile(
            title: Text('Semua Hari'),
            value: RadioDay.all_day,
            onChanged: (val) {
              setState(() {
                selectedRadioDay = val!;
              });
            },
            groupValue: selectedRadioDay,
          ),
        ),
      ],
    );
  }

  void actionSubmit() async {
    setState(() {
      listStaff.clear();
      listNoInduk.clear();
      // print(
      //     'listStaff.length : ${listStaff.length}; listNoInduk.length : ${listNoInduk.length}');
    });

    // fetch data master staff berdasarkan unit kerja
    Query queryStaff;
    CollectionReference ref = FirebaseFirestore.instance.collection('staff');
    // Jika kolom cari berdasarkan no induk berisi
    if (noIndukCont.text.isNotEmpty) {
      queryStaff = ref.where('no_induk', isEqualTo: noIndukCont.text);
      // print('cari staff berdasarkan no_induk : ${noIndukCont.text}');
    } else {
      // Jika dropdown unit kerja berisi
      queryStaff = ref.where('unit_kerja',
          isEqualTo: FirebaseFirestore.instance
              .collection('unit_kerja')
              .doc(selectedUnitKerja!.idDoc));
      // print('cari staff berdasarkan unit_kerja : $selectedUnitKerja');
    }

    QuerySnapshot staffSnapshot =
        await queryStaff.where('is_aktif', isEqualTo: true).get();
    staffSnapshot.docs.forEach((element) {
      Staff staff = Staff.fromJson(element.data() as Map<String, dynamic>);
      print('masukkan data ${staff.nama} ${staff.UID}');
      listStaff.add(staff);
      listNoInduk.add(staff.noInduk!);
    });
    listStaff.sort((a, b) => a.nama!.compareTo(b.nama!));
    // end of fetch data master staff

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('pengajuan')
        .where('time_create',
            isGreaterThanOrEqualTo: DateTime.parse(dateTxtContFrom.text))
        .where('time_create',
            isLessThan:
                DateTime.parse(dateTxtContTo.text).add(const Duration(days: 1)))
        .where('uid', whereIn: listStaff.map((s) => s.UID).toList())
        .get();

    pengajuans = snapshot.docs
        .map((p) => Pengajuan.fromJson(p.data() as Map<String, dynamic>, p.id))
        .toList();
    pengajuans.asMap().forEach((index, p) async {
      DocumentSnapshot s = await FirebaseFirestore.instance
          .collection(Staff.collectionName)
          .doc(p.uid)
          .get();

      Staff staff = Staff.fromJson(s.data() as Map<String, dynamic>);
      pengajuans[index].staff = staff;
    });
    setState(() {});
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
                    renderDatePicker(context, dateTxtContFrom, 'Dari tanggal'),
                    const SizedBox(width: 10),
                    renderDatePicker(context, dateTxtContTo, 'Hingga tanggal'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    renderEditText(noIndukCont, 'Cari berdasarkan Nomor Induk'),
                    const SizedBox(width: 10),
                    Flexible(
                        child: _dropDownField('Unit Kerja', selectedUnitKerja,
                            staffSession.unitKerjaParentCol!)),
                  ],
                ),
                // Text('Tampilkan Berdasarkan'),
                renderRadioFilterHari(),
                const SizedBox(height: 10),
                Center(
                  child: Row(
                    children: [
                      Expanded(
                          child: MaterialButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            actionSubmit();
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
}
