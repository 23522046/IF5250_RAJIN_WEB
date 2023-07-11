import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:if5250_rajin_apps_web/model/unit_kerja.dart';
import 'package:intl/intl.dart';

import '../../../model/presensi.dart';
import '../../../model/staff.dart';
import '../../../model/staff_presensi.dart';
import '../../../model/sys_config.dart';
import '../../../utils/util.dart';
import 'dart:js' as js;

class AbsensiTable extends StatefulWidget {
  final Query queryPresensi;
  final List<Staff> listStaff;
  final DateTime? startDate, endDate;
  final RadioDay selectedRadioDay;
  final UnitKerja unitKerja;

  const AbsensiTable(
      {required this.queryPresensi,
      required this.listStaff,
      this.startDate,
      this.endDate,
      required this.selectedRadioDay,
      required this.unitKerja,
      Key? key})
      : super(key: key);

  @override
  AbsensiTableState createState() => AbsensiTableState();
}

class AbsensiTableState extends State<AbsensiTable> {
  List<DateTime>? listDateTime;

  @override
  Widget build(BuildContext context) {
    print(widget.unitKerja.unitKerjaParentCol!.jamKerja);
    // fungsi untuk mendapatkan list hari berdasarkan inputan tanggal awal dan akhir
    listDateTime = getDaysInBeteween(widget.startDate, widget.endDate,
        selectedRadioDay: widget.selectedRadioDay);

    // print('ada ${listDateTime!.length} hari');
    var screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width / 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.listStaff.length,
          itemBuilder: (BuildContext context, int i) {
            Staff staff = widget.listStaff[i];

            Stream<QuerySnapshot> presensis = widget.queryPresensi
                .where('uid', isEqualTo: staff.UID)
                .snapshots();

            return renderCardPresensi(presensis, i);
          },
        ),
      ),
    );
  }

  Card renderCardPresensi(Stream<QuerySnapshot<Object?>> presensis, int i) {
    return Card(
        child: StreamBuilder<QuerySnapshot>(
            stream: presensis,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Terjadi kesalahan : ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return renderLoadingWidget();
              }

              int indexTable = 0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        renderRichText('Kode Pegawai : ',
                            '${widget.listStaff[i].noInduk}'),
                        renderRichText(
                            'Nama Pegawai : ', '${widget.listStaff[i].nama}'),
                        renderRichText(
                            'Nama Departemen : ', '${widget.unitKerja.nama}'),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      // columnSpacing: 56,
                      columns: renderTableHead(),
                      rows: listDateTime!.map((DateTime dateTime) {
                        indexTable++;

                        // dapatkan presensi dari docs, berdasarkan har
                        Presensi? presensi =
                            getFromDocs(snapshot.data?.docs, dateTime);

                        // print("presensi : $presensi");

                        // dapatkan master jam kerja berdasarkan input nama hari
                        MasterJamKerja masterJamKerja = getMasterJamkerja(
                            dateTime,
                            presensi,
                            widget.unitKerja.unitKerjaParentCol!.jamKerja!);

                        // print('masterJamKerja : $masterJamKerja');

                        // jika tidak ada absen di hari itu
                        if (presensi == null) {
                          return renderRowEmptyData(
                              indexTable, dateTime, masterJamKerja);
                        }

                        return renderRowData(indexTable, dateTime,
                            masterJamKerja, presensi, context, i);
                      }).toList(),
                    ),
                  ),
                ],
              );
            }));
  }

  Center renderLoadingWidget() {
    return const Center(
        child: Padding(
      padding: EdgeInsets.all(16.0),
      child: CircularProgressIndicator(),
    ));
  }

  DataRow renderRowData(
      int indexTable,
      DateTime dateTime,
      MasterJamKerja masterJamKerja,
      Presensi presensi,
      BuildContext context,
      int i) {
    String jamKerja =
        '${masterJamKerja.jamMasuk.timeNoSec}-${masterJamKerja.jamPulang.timeNoSec}';

    String kegiatan = presensi.jenis!.toUpperCase();
    String jamMasuk = presensi.waktuCekin;
    String jamKeluar = presensi.waktuCekout;
    String terlambat = presensi.terlambat(masterJamKerja),
        cepatPulang = presensi.cepatPulang(masterJamKerja),
        durasiKerja = presensi.durasiKerja(masterJamKerja),
        lembur = presensi.durasiLembur(masterJamKerja);
    String hari = dateTime.date.split(',').first;
    String tanggal = dateTime.date.split(',').last;

    return DataRow(
      cells: <DataCell>[
        DataCell(Text('$indexTable')),
        DataCell(Text(hari)),
        DataCell(Text(tanggal)),
        DataCell(Text(jamKerja)),
        DataCell(Text(kegiatan)),
        DataCell(SizedBox(
          width: 80,
          child: Text(
            jamMasuk,
            style: TextStyle(
                color: (terlambat.isNotEmpty) ? Colors.red : Colors.black87),
          ),
        )),
        DataCell(SizedBox(
          width: 90,
          child: Text(
            jamKeluar,
            style: TextStyle(
                color: (cepatPulang.isNotEmpty) ? Colors.red : Colors.black87),
          ),
        )),
        DataCell(Text(terlambat)),
        DataCell(SizedBox(width: 110, child: Text(cepatPulang))),
        DataCell(Text(durasiKerja)),
        DataCell(Row(children: [
          // checkbox lembur hanya muncul, jika staff pulang diatas jam pulang pada master jam kerja
          if (presensi.checkOut != null && (cepatPulang.isEmpty))
            Visibility(
              visible: false,
              child: Checkbox(
                  value: presensi.isLembur,
                  onChanged: (val) async {
                    // double data ketika ada onchange belum berhasil
                    indexTable = 0;
                    updateRecord(presensi, val!);
                  }),
            ),
          const SizedBox(width: 10),
          Text(lembur)
        ])),
        DataCell(Row(
          children: [
            TextButton(
                onPressed: () => js.context.callMethod('open', [
                      'https://maps.google.com?q=${presensi.checkIn.location.latitude},${presensi.checkIn.location.longitude}'
                    ]),
                child: const Text(
                  'Posisi Masuk',
                  style: TextStyle(color: Colors.blue),
                )),
            if (presensi.checkOut != null)
              TextButton(
                  onPressed: () => js.context.callMethod('open', [
                        'https://maps.google.com?q=${presensi.checkOut?.location.latitude},${presensi.checkOut?.location.longitude}'
                      ]),
                  child: const Text(
                    'Posisi Pulang',
                    style: TextStyle(color: Colors.blue),
                  )),
          ],
        )),
      ],
    );
  }

  DataRow renderRowEmptyData(
      int indexTable, DateTime dateTime, MasterJamKerja masterJamKerja) {
    String jamKerja =
        '${masterJamKerja.jamMasuk.timeNoSec}-${masterJamKerja.jamPulang.timeNoSec}';
    String hari = dateTime.date.split(',').first;
    String tanggal = dateTime.date.split(',').last;

    return DataRow(
      cells: <DataCell>[
        DataCell(Text('$indexTable')),
        DataCell(Text(hari)),
        DataCell(Text(tanggal)),
        DataCell(Text(jamKerja)),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
      ],
    );
  }

  RichText renderRichText(String label, String value) {
    return RichText(
      text: TextSpan(style: const TextStyle(color: Colors.black87), children: [
        TextSpan(
            text: label, style: const TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: value),
      ]),
    );
  }

  void updateRecord(Presensi p, bool isLembur) async {
    try {
      String tanggalPres =
          DateFormat('yyyy-MM-dd').format(p.checkIn.waktu.toDate());
      String idDoc = '${tanggalPres}_${p.staffId}';
      DocumentReference presensiReff =
          FirebaseFirestore.instance.collection('presensi').doc(idDoc);

      DocumentSnapshot presensi = await presensiReff.get();

      if (!presensi.exists) {
        throw ('Presensi dengan kode docs : $idDoc tidak ditemukan');
      }

      presensiReff.update({'is_lembur': isLembur});
      // print('is_lembur now : $isLembur');
    } catch (e) {
      alert(context: context, children: [Text(e.toString())]);
    }
  }

  renderTableHead() {
    return [
      '#',
      'HARI',
      'TANGGAL',
      'JAM KERJA',
      'KEGIATAN',
      'JAM MASUK',
      'JAM KELUAR',
      'TERLAMBAT',
      'CEPAT PULANG',
      'JAM EFEKTIF',
      'LEMBUR',
      'AKSI'
    ]
        .map((text) => DataColumn(
              label: Text(
                text,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ))
        .toList();
  }
}
