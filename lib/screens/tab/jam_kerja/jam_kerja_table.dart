import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:if5250_rajin_apps_web/model/batas_wilayah.dart';
import 'package:if5250_rajin_apps_web/model/jam_kerja.dart';
import 'package:if5250_rajin_apps_web/model/unit_kerja.dart';
import 'package:if5250_rajin_apps_web/screens/tab/batas_wilayah/form/batas_wilayah_set_polygon.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/util.dart';
import '../../../model/staff.dart';

class JamKerjaTable extends StatefulWidget {
  final List<TextEditingController> listWeekdayCont;
  final List<TextEditingController> listJamMasukCont;
  final List<TextEditingController> listJamPulangCont;
  List<JamKerja> jamKerja;
  Staff staffSession;
  VoidCallback reloadData;

  JamKerjaTable(
      {required this.jamKerja,
      required this.staffSession,
      required this.reloadData,
      required this.listWeekdayCont,
      required this.listJamMasukCont,
      required this.listJamPulangCont,
      Key? key})
      : super(key: key);

  @override
  JamKerjaTableState createState() => JamKerjaTableState();
}

class JamKerjaTableState extends State<JamKerjaTable> {
  List<DateTime>? listDateTime;

  @override
  void initState() {
    widget.jamKerja.asMap().forEach((index, j) {
      widget.listWeekdayCont[index].text = '${j.weekday}';
      widget.listJamMasukCont[index].text = j.masuk;
      widget.listJamPulangCont[index].text = j.pulang;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    int _indexTable = 0;

    var weekdayFormatter =
        MaskTextInputFormatter(mask: '#', filter: {"#": RegExp(r'[1-7]')});
    var jamFormatter = MaskTextInputFormatter(
        mask: '##:##:##', filter: {"#": RegExp(r'[0-9]')});

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width / 15),
      child: Card(
        child: Align(
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: <DataColumn>[
                _renderCol('HARI'),
                _renderCol('INDEKS HARI'),
                _renderCol('JAM MASUK'),
                _renderCol('JAM PULANG'),
                _renderCol('AKSI'),
              ],
              rows: widget.listWeekdayCont.asMap().entries.map((entry) {
                JamKerja? jamKerja = (entry.key >= widget.jamKerja.length)
                    ? null
                    : widget.jamKerja[entry.key];

                return DataRow(cells: [
                  DataCell(Text(jamKerja?.dayName() ?? '')),
                  DataCell(TextFormField(
                    keyboardType: TextInputType.number,
                    controller: widget.listWeekdayCont[entry.key],
                    inputFormatters: [weekdayFormatter],
                    decoration: const InputDecoration(
                        hintText: 'Masukkan indeks hari (ex : 1-7)'),
                  )),
                  DataCell(TextFormField(
                    controller: widget.listJamMasukCont[entry.key],
                    inputFormatters: [jamFormatter],
                    decoration:
                        const InputDecoration(hintText: 'Masukkan jam masuk'),
                  )),
                  DataCell(TextFormField(
                    controller: widget.listJamPulangCont[entry.key],
                    inputFormatters: [jamFormatter],
                    decoration:
                        const InputDecoration(hintText: 'Masukkan jam pulang'),
                  )),
                  DataCell(Row(children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      label: const Text('HAPUS',
                          style: TextStyle(color: Colors.blue)),
                      onPressed: () => alertAct(
                          context: context,
                          content: const Text('Anda yakin ingin menghapus?'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  if (jamKerja != null) {
                                    deleteRecord(jamKerja.weekday)
                                        .then((value) {
                                      widget.reloadData();
                                      Navigator.of(context).pop();
                                    });
                                  } else {
                                    // delete row UI by index only not to DB
                                    deleteRow(entry.key);
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text('YA')),
                            TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('BATAL'))
                          ]),
                    ),
                  ]))
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  DataColumn _renderCol(String label) {
    return DataColumn(
      label: Text(
        '$label',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }

  Future deleteRecord(int index) async {
    try {
      DocumentReference ref = FirebaseFirestore.instance
          .collection(UnitKerja.collectionName)
          .doc(widget.staffSession.unitKerjaParent!.id);
      DocumentSnapshot snapshot = await ref.get();

      UnitKerja unitKerja = UnitKerja.fromJson(
          snapshot.data() as Map<String, dynamic>, snapshot.id);

      unitKerja.jamKerja?.removeWhere((b) => b.weekday == index);

      ref.update({
        'jam_kerja': unitKerja.jamKerja?.map((b) => b.toJson()).toList() ?? [],
        'time_update': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print(e.toString());
    }
    return false;
  }

  void deleteRow(int index) {
    setState(() {
      widget.listWeekdayCont.removeAt(index);
      widget.listJamMasukCont.removeAt(index);
      widget.listJamPulangCont.removeAt(index);
    });
  }
}
