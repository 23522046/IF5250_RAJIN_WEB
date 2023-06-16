import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../model/presensi.dart';
import '../../../model/staff.dart';
import '../../../model/staff_presensi.dart';
import '../../../model/sys_config.dart';
import '../../../utils/util.dart';
import 'dart:js' as js;

import 'detail.dart';

class AbsensiTable extends StatefulWidget {
  final Query queryPresensi;
  final List<Staff> listStaff;
  final DateTime? startDate, endDate;
  final RadioDay selectedRadioDay;

  AbsensiTable(
      {required this.queryPresensi,
      required this.listStaff,
      this.startDate,
      this.endDate,
      required this.selectedRadioDay,
      Key? key})
      : super(key: key);

  @override
  AbsensiTableState createState() => AbsensiTableState();
}

class AbsensiTableState extends State<AbsensiTable> {
  List<DateTime>? listDateTime;
  List<StaffPresensi> staffPresensis = <StaffPresensi>[];

  @override
  Widget build(BuildContext context) {
    staffPresensis.clear();

    // fungsi untuk mendapatkan list hari berdasarkan inputan tanggal awal dan akhir
    listDateTime = getDaysInBeteween(widget.startDate, widget.endDate,
        selectedRadioDay: widget.selectedRadioDay);

    print('ada ${listDateTime!.length} hari');
    var screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width / 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.listStaff.length,
          itemBuilder: (BuildContext context, int i) {
            Staff _staff = widget.listStaff[i];

            Stream<QuerySnapshot> presensis = widget.queryPresensi
                .where('uid', isEqualTo: _staff.UID)
                .snapshots();

            return Card(
              child: (presensis == null)
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                          child: Text(
                        'Isi kolom pencarian, kemudian klik tombol cari',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      )),
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: presensis,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          print(snapshot.error);
                          return Text('Terjadi kesalahan : ${snapshot.error}');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ));
                        }

                        int _indexTable = 0;
                        StaffPresensi _staffPresensi =
                            StaffPresensi(staff: _staff);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                        style: TextStyle(color: Colors.black87),
                                        children: [
                                          TextSpan(
                                              text: 'Kode Pegawai : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                              text:
                                                  '${widget.listStaff[i].noInduk}'),
                                        ]),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                        style: TextStyle(color: Colors.black87),
                                        children: [
                                          TextSpan(
                                              text: 'Nama Pegawai : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                              text:
                                                  '${widget.listStaff[i].nama}'),
                                        ]),
                                  ),
                                  // RichText(
                                  //   text: TextSpan(
                                  //       style: TextStyle(color: Colors.black87),
                                  //       children: [
                                  //         TextSpan(
                                  //             text: 'Jabatan Struktural : ',
                                  //             style: TextStyle(
                                  //                 fontWeight: FontWeight.bold)),
                                  //         TextSpan(
                                  //             text:
                                  //                 '${widget.listStaff[i].jabatanStruktural}'),
                                  //       ]),
                                  // ),
                                  // RichText(
                                  //   text: TextSpan(
                                  //       style: TextStyle(color: Colors.black87),
                                  //       children: [
                                  //         TextSpan(
                                  //             text: 'Nama Departemen : ',
                                  //             style: TextStyle(
                                  //                 fontWeight: FontWeight.bold)),
                                  //         TextSpan(
                                  //             text:
                                  //                 '${widget.listStaff[i].unitKerja}'),
                                  //       ]),
                                  // )
                                ],
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                // columnSpacing: 56,
                                columns: const <DataColumn>[
                                  DataColumn(
                                    label: Text(
                                      '#',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'HARI',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'TANGGAL',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'JAM KERJA',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'KEGIATAN',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'JAM MASUK',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'JAM KELUAR',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'TERLAMBAT',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'CEPAT PULANG',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'JAM EFEKTIF',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'LEMBUR',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'AKSI',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ],
                                rows: listDateTime!.map((DateTime dateTime) {
                                  _indexTable++;

                                  // dapatkan presensi dari docs, berdasarkan har
                                  Presensi? presensi = getFromDocs(
                                      snapshot.data?.docs, dateTime);

                                  print("presensi : $presensi");

                                  // dapatkan master jam kerja berdasarkan input nama hari
                                  MasterJamKerja masterJamKerja =
                                      getMasterJamkerja(dateTime, presensi);

                                  print('masterJamKerja : $masterJamKerja');

                                  bool isLembur = presensi?.isLembur ?? false;
                                  String hari =
                                      '${dateTime.date.split(',').first}';
                                  String tanggal =
                                      '${dateTime.date.split(',').last}';
                                  String jamKerja = (masterJamKerja != null)
                                      ? '${masterJamKerja.jamMasuk.timeNoSec}-${masterJamKerja.jamPulang.timeNoSec}'
                                      : '';
                                  String jamMasuk = '',
                                      jamKeluar = '',
                                      terlambat = '',
                                      cepatPulang = '',
                                      durasiKerja = '',
                                      lembur = '',
                                      kegiatan = '';

                                  // jika tidak ada absen di hari itu
                                  if (presensi == null) {
                                    // init variable untuk presensi export
                                    PresensiExport _presensiExp =
                                        PresensiExport(
                                            tglAsli: dateTime,
                                            isLembur: isLembur,
                                            hari: hari,
                                            tanggal: tanggal,
                                            jamKerja: jamKerja);
                                    _staffPresensi.presensiExport =
                                        _presensiExp;
                                    if (_indexTable == listDateTime?.length) {
                                      staffPresensis.add(_staffPresensi);
                                    }
                                    return DataRow(
                                      cells: <DataCell>[
                                        DataCell(Text('$_indexTable')),
                                        DataCell(Text('$hari')),
                                        DataCell(Text('$tanggal')),
                                        DataCell(Text('$jamKerja')),
                                        DataCell(Text('')),
                                        DataCell(Text('')),
                                        DataCell(Text('')),
                                        DataCell(Text('$terlambat')),
                                        DataCell(Text('$cepatPulang')),
                                        DataCell(Text('$durasiKerja')),
                                        DataCell(Text('')),
                                        DataCell(Row(
                                          children: [],
                                        )),
                                      ],
                                    );
                                  } else {
                                    kegiatan =
                                        '${presensi.jenis!.toUpperCase()}';
                                    jamMasuk = '${presensi.waktuCekin}';
                                    jamKeluar = '${presensi.waktuCekout}';

                                    // jika terlambat
                                    if (masterJamKerja != null &&
                                        presensi.isTerlambat(masterJamKerja)) {
                                      // print(
                                      //     'hitung selisih telat ${masterJamKerja.jamMasuk.date} ${masterJamKerja.jamMasuk.time} dengan ${presensi.checkIn?.waktu?.date} ${presensi.checkIn?.waktu?.time}');
                                      terlambat =
                                          presensi.terlambat(masterJamKerja);
                                    }

                                    if (presensi.checkOut != null) {
                                      // jika pulang cepat
                                      if (masterJamKerja != null &&
                                          presensi
                                              .isCepatPulang(masterJamKerja)) {
                                        cepatPulang = presensi
                                            .cepatPulang(masterJamKerja);
                                        print('cepatPulang : $cepatPulang');
                                      }

                                      // hitung durasi kerja
                                      durasiKerja =
                                          presensi.durasiKerja(masterJamKerja);

                                      // jika lembur
                                      if (isLembur &&
                                          presensi.checkOut != null) {
                                        // jika lembur di hari kerja
                                        lembur = presensi
                                            .durasiLembur(masterJamKerja);
                                      }
                                    }

                                    PresensiExport _presensiExp =
                                        PresensiExport(
                                            tglAsli:
                                                presensi.checkIn.waktu.toDate(),
                                            isLembur: isLembur,
                                            ket: presensi.ket,
                                            isEdited: presensi.isEdited,
                                            hari: hari,
                                            tanggal: tanggal,
                                            jamKerja: jamKerja,
                                            kegiatan: kegiatan,
                                            lembur: lembur,
                                            terlambat: terlambat,
                                            cepatPulang: cepatPulang,
                                            jamEfektif: durasiKerja,
                                            jamMasuk: TextWStyle(
                                                text: jamMasuk,
                                                color: (terlambat.length > 0)
                                                    ? Colors.red
                                                    : Colors.black87),
                                            jamKeluar: TextWStyle(
                                                text: jamKeluar,
                                                color: (cepatPulang.length > 0)
                                                    ? Colors.red
                                                    : Colors.black87));

                                    _staffPresensi.presensiExport =
                                        _presensiExp;
                                    if (_indexTable == listDateTime!.length) {
                                      staffPresensis.add(_staffPresensi);
                                    }
                                    return DataRow(
                                      cells: <DataCell>[
                                        DataCell(Text('$_indexTable')),
                                        DataCell(Text('$hari')),
                                        DataCell(Text('$tanggal')),
                                        DataCell(Text('$jamKerja')),
                                        DataCell(Text('$kegiatan')),
                                        DataCell(Container(
                                          width: 80,
                                          child: Text(
                                            '$jamMasuk',
                                            style: TextStyle(
                                                color: (terlambat.length > 0)
                                                    ? Colors.red
                                                    : Colors.black87),
                                          ),
                                        )),
                                        DataCell(Container(
                                          width: 90,
                                          child: Text(
                                            jamKeluar,
                                            style: TextStyle(
                                                color: (cepatPulang.length > 0)
                                                    ? Colors.red
                                                    : Colors.black87),
                                          ),
                                        )),
                                        DataCell(Text('$terlambat')),
                                        DataCell(Container(
                                            width: 110,
                                            child: Text('$cepatPulang'))),
                                        DataCell(Text('$durasiKerja')),
                                        DataCell(Row(children: [
                                          // checkbox lembur hanya muncul, jika staff pulang diatas jam pulang pada master jam kerja
                                          if (presensi.checkOut != null &&
                                              (cepatPulang.isEmpty ?? false))
                                            Visibility(
                                              visible: false,
                                              child: Checkbox(
                                                  value: isLembur,
                                                  onChanged: (val) async {
                                                    // double data ketika ada onchange belum berhasil
                                                    _indexTable = 0;
                                                    clearData(presensi);
                                                    updateRecord(
                                                        presensi, val!);
                                                  }),
                                            ),
                                          SizedBox(width: 10),
                                          Text('$lembur')
                                        ])),
                                        DataCell(Row(
                                          children: [
                                            TextButton(
                                                onPressed: () => showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (context) {
                                                      return DetailPage(
                                                          presensi: presensi,
                                                          staff: widget
                                                              .listStaff[i]);
                                                    }),
                                                child: Visibility(
                                                  visible: false,
                                                  child: Text(
                                                    'Ubah Status',
                                                    style: TextStyle(
                                                        color: Colors.blue),
                                                  ),
                                                )),
                                            TextButton(
                                                onPressed: () => js.context
                                                        .callMethod('open', [
                                                      'https://maps.google.com?q=${presensi.checkIn.location.latitude},${presensi.checkIn.location.longitude}'
                                                    ]),
                                                child: Text(
                                                  'Posisi Masuk',
                                                  style: TextStyle(
                                                      color: Colors.blue),
                                                )),
                                            TextButton(
                                                onPressed: () => js.context
                                                        .callMethod('open', [
                                                      'https://maps.google.com?q=${presensi.checkOut?.location.latitude},${presensi.checkOut?.location.longitude}'
                                                    ]),
                                                child: Text(
                                                  'Posisi Pulang',
                                                  style: TextStyle(
                                                      color: Colors.blue),
                                                )),
                                          ],
                                        )),
                                      ],
                                    );
                                  }
                                }).toList(),
                              ),
                            ),
                          ],
                        );
                      }),
            );
          },
        ),
      ),
    );
  }

  void methodA() {
    // Navigator.of(context).push(MaterialPageRoute(
    //     builder: (context) => ExportPdf(
    //         listStaff: staffPresensis,
    //         startDate: widget.startDate,
    //         endDate: widget.endDate)));
  }

  void methodB() {
    // Navigator.of(context).push(MaterialPageRoute(
    //     builder: (context) => ExportHasil(
    //         listStaff: staffPresensis,
    //         startDate: widget.startDate,
    //         endDate: widget.endDate)));
  }

  void updateRecord(Presensi _presensi, bool isLembur) async {
    try {
      String tanggalPres =
          DateFormat('yyyy-MM-dd').format(_presensi.checkIn.waktu.toDate());
      String idDoc = '${tanggalPres}_${_presensi.staffId}';
      DocumentReference presensiReff =
          FirebaseFirestore.instance.collection('presensi').doc(idDoc);

      DocumentSnapshot presensi = await presensiReff.get();

      if (!presensi.exists) {
        throw ('Presensi dengan kode docs : $idDoc tidak ditemukan');
      }

      presensiReff.update({'is_lembur': isLembur});
      print('is_lembur now : $isLembur');
    } catch (e) {
      alert(context: context, children: [Text(e.toString())]);
    }
  }

  void clearData(Presensi presensi) async {
    // jika sudah ada data presensi pegawai itu clearkan dulu, terjadi ketika ada edit data seperti check/uncheck cb lembur
    StaffPresensi sp = staffPresensis.firstWhere(
        (staffPresensi) => staffPresensi.staff.noInduk == presensi.staffId);
    print('sp.presensis.length : ${sp.presensis.length}');
    sp.presensis.clear();
    print('sp.presensis.length : ${sp.presensis.length}');
  }
}
