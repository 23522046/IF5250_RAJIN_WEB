import 'package:flutter/material.dart';
import 'package:if5250_rajin_apps_web/model/unit_kerja.dart';
import 'package:if5250_rajin_apps_web/screens/tab/unit_kerja/unit_kerja_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/staff.dart';

class UnitKerjaTable extends StatefulWidget {
  List<UnitKerja> unitKerjas;
  Staff staffSession;
  VoidCallback reloadData;

  UnitKerjaTable(
      {required this.unitKerjas,
      required this.staffSession,
      required this.reloadData,
      Key? key})
      : super(key: key);

  @override
  UnitKerjaTableState createState() => UnitKerjaTableState();
}

class UnitKerjaTableState extends State<UnitKerjaTable> {
  List<DateTime>? listDateTime;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    int _indexTable = 0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width / 15),
      child: Card(
        child: Align(
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: <DataColumn>[
                _renderCol('#'),
                _renderCol('NAMA'),
                _renderCol('AKSI'),
              ],
              rows: widget.unitKerjas.map((UnitKerja unitKerja) {
                _indexTable++;

                return DataRow(cells: [
                  DataCell(Text('$_indexTable')),
                  DataCell(Text('${unitKerja.nama}')),
                  DataCell(Row(children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      label: const Text('EDIT',
                          style: TextStyle(color: Colors.blue)),
                      onPressed: () async {
                        await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return UnitKerjaForm(
                                  unitKerja: unitKerja,
                                  staffSession: widget.staffSession);
                            });
                        widget.reloadData();
                      },
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
}
