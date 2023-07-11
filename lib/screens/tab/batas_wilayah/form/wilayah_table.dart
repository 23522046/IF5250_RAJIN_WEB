import 'package:flutter/material.dart';
import 'package:if5250_rajin_apps_web/model/batas_wilayah.dart';
import 'package:if5250_rajin_apps_web/model/unit_kerja.dart';
import 'package:if5250_rajin_apps_web/screens/tab/batas_wilayah/form/batas_wilayah_set_polygon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../model/staff.dart';

class WilayahTable extends StatefulWidget {
  BatasWilayah? batasWilayah;
  Staff staffSession;
  VoidCallback drawPolygonFunc, clearMapsFunc;
  final TextEditingController namaCont;

  WilayahTable(
      {this.batasWilayah,
      required this.staffSession,
      required this.namaCont,
      Key? key,
      required this.drawPolygonFunc,
      required this.clearMapsFunc})
      : super(key: key);

  @override
  WilayahTableState createState() => WilayahTableState();
}

class WilayahTableState extends State<WilayahTable> {
  List<DateTime>? listDateTime;

  @override
  void initState() {
    widget.namaCont.text = widget.batasWilayah?.nama ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: <DataColumn>[
              _renderCol('NAMA'),
              _renderCol('JUMLAH TITIK POLYGON'),
              _renderCol(''),
            ],
            rows: [
              DataRow(cells: [
                DataCell(TextFormField(
                  decoration:
                      const InputDecoration(hintText: 'Masukkan nama wilayah'),
                  controller: widget.namaCont,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Wajib diisi';
                    }
                  },
                )),
                DataCell(Text('${widget.batasWilayah?.polygons?.length ?? 0}')),
                DataCell(Row(children: [
                  MaterialButton(
                    color: Colors.red,
                    onPressed: widget.clearMapsFunc,
                    child: const Text('HAPUS MARKER',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 20),
                  MaterialButton(
                    color: Colors.purple,
                    onPressed: widget.drawPolygonFunc,
                    child: const Text('RELOAD POLYGON',
                        style: TextStyle(color: Colors.white)),
                  ),
                ]))
              ])
            ],
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
