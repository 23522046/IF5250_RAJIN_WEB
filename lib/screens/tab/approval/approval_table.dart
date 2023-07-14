import 'dart:js' as js;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/pengajuan.dart';
import '../../../model/presensi.dart';
import '../../../model/unit_kerja.dart';
import '../../../utils/util.dart';

class ApprovalTable extends StatefulWidget {
  final RadioDay selectedRadioDay;
  List<Pengajuan> pengajuans;
  final UnitKerja unitKerja;

  ApprovalTable(
      {required this.pengajuans,
      required this.selectedRadioDay,
      required this.unitKerja,
      Key? key})
      : super(key: key);

  @override
  ApprovalTableState createState() => ApprovalTableState();
}

class ApprovalTableState extends State<ApprovalTable> {
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
                _renderCol('NOMOR INDUK'),
                _renderCol('NAMA'),
                _renderCol('JENIS'),
                _renderCol('MULAI TANGGAL'),
                _renderCol('HINGGA TANGGAL'),
                _renderCol('STATUS'),
                _renderCol('DIAJUKAN PADA'),
                _renderCol('AKSI'),
              ],
              rows: widget.pengajuans.map((Pengajuan pengajuan) {
                _indexTable++;

                return DataRow(cells: [
                  DataCell(Text('$_indexTable')),
                  DataCell(SelectableText('${pengajuan.staff?.noInduk}')),
                  DataCell(Text('${pengajuan?.staff?.nama ?? '-'}')),
                  DataCell(Text('${pengajuan.jenis?.toUpperCase()}')),
                  DataCell(Text('${pengajuan.mulaiTanggal?.date}')),
                  DataCell(Text('${pengajuan.sampaiTanggal?.date}')),
                  DataCell(Text('${pengajuan.status?.toUpperCase()}')),
                  DataCell(Text('${pengajuan.timeCreate?.date}')),
                  DataCell(Row(children: [
                    if (pengajuan.status == 'terkirim')
                      TextButton.icon(
                        icon: Icon(Icons.sync, color: Colors.blue),
                        label: Text('VERIFIKASI',
                            style: TextStyle(color: Colors.blue)),
                        onPressed: () {
                          showKonfirmasi(context, pengajuan, 'verifikasi');
                        },
                      ),
                    if (pengajuan.status == 'verifikasi')
                      TextButton.icon(
                        icon: Icon(Icons.verified, color: Colors.blue),
                        label: Text('TERIMA',
                            style: TextStyle(color: Colors.blue)),
                        onPressed: () {
                          showKonfirmasi(context, pengajuan, 'terima');
                        },
                      ),
                    if (pengajuan.status == 'verifikasi')
                      TextButton.icon(
                        icon: Icon(Icons.close, color: Colors.blue),
                        label: Text(
                          'TOLAK',
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () {
                          showKonfirmasi(context, pengajuan, 'tolak');
                        },
                      ),
                    if (pengajuan.status == 'terima' ||
                        pengajuan.status == 'tolak')
                      TextButton.icon(
                        icon: Icon(Icons.info, color: Colors.blue),
                        label: Text(
                          'INFORMASI',
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () {
                          showInformasi(context, pengajuan);
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

  void showKonfirmasi(
      BuildContext context, Pengajuan pengajuan, String status) {
    showDialog(
        context: context,
        builder: (context) {
          List<Widget> children = [
            Text('No Induk : ', style: TextStyle(fontSize: 12)),
            Text('${pengajuan.staff?.noInduk}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Nama : ', style: TextStyle(fontSize: 12)),
            Text('${pengajuan?.staff?.nama ?? '-'}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Jenis : ', style: TextStyle(fontSize: 12)),
            Text('${pengajuan.jenis?.toUpperCase()}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Mulai Tangal : ', style: TextStyle(fontSize: 12)),
            Text('${pengajuan.mulaiTanggal?.date}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Hingga Tanggal : ', style: TextStyle(fontSize: 12)),
            Text('${pengajuan.sampaiTanggal?.date}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Keterangan : ', style: TextStyle(fontSize: 12)),
            Text('${pengajuan.ket}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Dokumen Pendukung : ', style: TextStyle(fontSize: 12)),
          ];

          pengajuan.dokPendukung?.forEach((foto) {
            children.add(Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(foto),
            ));
          });
          return AlertDialog(
            title: Text('Anda yakin ingin $status?'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
            actions: [
              MaterialButton(
                color: Colors.pink,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(status.toUpperCase()),
                ),
                onPressed: () {
                  updateData(status, pengajuan);
                },
              ),
              TextButton(
                child: Text('BATAL'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }

  void showInformasi(BuildContext context, Pengajuan pengajuan) {
    showDialog(
        context: context,
        builder: (context) {
          List<Widget> children = [
            Text('Nomor Induk : ', style: TextStyle(fontSize: 12)),
            Text('${pengajuan.staff?.noInduk}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Nama : ', style: TextStyle(fontSize: 12)),
            Text('${pengajuan?.staff?.nama ?? '-'}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Jenis : ', style: TextStyle(fontSize: 12)),
            Text('${pengajuan.jenis?.toUpperCase()}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Mulai Tangal : ', style: TextStyle(fontSize: 12)),
            Text('${pengajuan.mulaiTanggal?.date}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Hingga Tanggal : ', style: TextStyle(fontSize: 12)),
            Text('${pengajuan.sampaiTanggal?.date}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Keterangan : ', style: TextStyle(fontSize: 12)),
            Text('${pengajuan.ket}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Log Aktifitas : ', style: TextStyle(fontSize: 12)),
            Text('${pengajuan.logAktifitas}',
                style: TextStyle(fontStyle: FontStyle.italic)),
            SizedBox(height: 5),
            Text('Dokumen Pendukung : ', style: TextStyle(fontSize: 12)),
          ];

          pengajuan.dokPendukung?.forEach((foto) {
            children.add(Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(foto),
            ));
          });
          return AlertDialog(
            title: Text('INFORMASI ${pengajuan.jenis?.toUpperCase()}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
            actions: [
              MaterialButton(
                color: Colors.pink,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('TUTUP'),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void updateData(String status, Pengajuan pengajuan) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // generate absensi dilakukan jika aksi terima
      String pesan = "Pengusulan ${pengajuan.jenis} anda telah ";
      if (status == 'terima') {
        pesan += ' diterima';
        getDaysInBeteween(pengajuan.mulaiTanggal?.toDate(),
                pengajuan.sampaiTanggal?.toDate(),
                selectedRadioDay: (pengajuan.jenis == 'dinas luar')
                    ? RadioDay.all_day
                    : RadioDay.work_day)
            .forEach((day) {
          String pathDoc = DateFormat('yyyy-MM-dd').format(day);
          DocumentReference pengajuanReff = FirebaseFirestore.instance
              .collection('presensi')
              .doc('${pengajuan.uid}_${pathDoc}');

          print('generating absensi ${pengajuan.uid} $pathDoc');
          DateTime waktuCekin = DateTime(day.year, day.month, day.day, 08, 00);
          DateTime waktuCekout = (pengajuan.jenis == 'dinas luar')
              ? DateTime(day.year, day.month, day.day, 15, 00)
              : waktuCekin; // jika DL, waktu check out jam 15:00, else 08:00
          pengajuanReff.set(<String, dynamic>{
            'check_in': <String, dynamic>{
              'is_mock_location': false,
              'location':
                  const GeoPoint(0.46623168996552977, 101.35609433302993),
              'waktu': Timestamp.fromDate(waktuCekin),
            },
            'check_out': <String, dynamic>{
              'is_mock_location': false,
              'location':
                  const GeoPoint(0.46623168996552977, 101.35609433302993),
              'waktu': Timestamp.fromDate(waktuCekout),
            },
            'is_lembur': false,
            'jenis': pengajuan.jenis,
            'ket': pengajuan.ket,
            'uid': pengajuan.uid,
            'time_create': Timestamp.fromDate(
                waktuCekin), // kalau bisa ganti dengan waktu timestamp firebase, tapi cari kenapa diadmin yang tampil malah berdasarkan jam cekin
            'time_update': null,
            'pengajuan_id': pengajuan.docId,
          });
        });
      }

      pesan += ' ditolak';

      DocumentReference pengajuanReff = FirebaseFirestore.instance
          .collection('pengajuan')
          .doc(pengajuan.docId);

      print(pengajuanReff);
      pengajuanReff.update({
        'status': status,
      });

      // send notif ke pegawai/dosen
      // bool isNotifSend = await sendNotif(
      //     [pengajuan.staff?.playerId ?? ''],
      //     'Halo ${pengajuan.staff?.nama}',
      //     'Usulan ${pengajuan.jenis} anda telah di$status');
      // print('isNotifSend : $isNotifSend');

      Navigator.of(context).pop();
    } catch (e) {
      alert(context: context, title: 'Perhatian!', children: [Text('$e')]);
    }
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
