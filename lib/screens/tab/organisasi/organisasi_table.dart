import 'package:flutter/material.dart';
import 'package:if5250_rajin_apps_web/model/unit_kerja.dart';
import 'package:if5250_rajin_apps_web/screens/tab/unit_kerja/unit_kerja_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/staff.dart';
import 'organisasi_form.dart';

class OrganisasiTable extends StatefulWidget {
  List<UnitKerja> unitKerjas;
  Staff staffSession;
  VoidCallback reloadData;

  OrganisasiTable(
      {required this.unitKerjas,
      required this.staffSession,
      required this.reloadData,
      Key? key})
      : super(key: key);

  @override
  OrganisasiTableState createState() => OrganisasiTableState();
}

class OrganisasiTableState extends State<OrganisasiTable> {
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
                _renderCol('INSTANSI'),
                _renderCol('AKUN ADMINISTRATOR'),
                _renderCol('AKSI'),
              ],
              rows: widget.unitKerjas.map((UnitKerja unitKerja) {
                _indexTable++;

                return DataRow(cells: [
                  DataCell(Text('$_indexTable')),
                  DataCell(Text('${unitKerja.nama}')),
                  DataCell(Text(unitKerja.adminStaffToString())),
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
                              return OrganisasiForm(
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
