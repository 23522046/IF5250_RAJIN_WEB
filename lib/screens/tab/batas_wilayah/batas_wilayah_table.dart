import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:if5250_rajin_apps_web/model/batas_wilayah.dart';
import 'package:if5250_rajin_apps_web/model/unit_kerja.dart';
import 'package:if5250_rajin_apps_web/screens/tab/batas_wilayah/form/batas_wilayah_set_polygon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/util.dart';
import '../../../model/staff.dart';

class BatasWilayahTable extends StatefulWidget {
  List<BatasWilayah> batasWilayah;
  Staff staffSession;
  VoidCallback reloadData;

  BatasWilayahTable(
      {required this.batasWilayah,
      required this.staffSession,
      required this.reloadData,
      Key? key})
      : super(key: key);

  @override
  BatasWilayahTableState createState() => BatasWilayahTableState();
}

class BatasWilayahTableState extends State<BatasWilayahTable> {
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
              rows: widget.batasWilayah.map((BatasWilayah batasWilayah) {
                _indexTable++;

                return DataRow(cells: [
                  DataCell(Text('$_indexTable')),
                  DataCell(Text('${batasWilayah.nama}')),
                  DataCell(Row(children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      label: const Text('EDIT POLIGON',
                          style: TextStyle(color: Colors.blue)),
                      onPressed: () async {
                        bool res =
                            await Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => BatasWilayahSetPolygon(
                                      wilayah: batasWilayah,
                                      staffSession: widget.staffSession,
                                    )));
                        widget.reloadData();
                      },
                    ),
                    const SizedBox(width: 20),
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
                                  deleteRecord(batasWilayah.nama!)
                                      .then((value) {
                                    Navigator.of(context).pop(true);
                                    widget.reloadData();
                                  });
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

  // void showDialogKonfirmasi(
  //     BuildContext context, Staff batasWilayah, String status) {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         List<Widget> children = [
  //           Text('No Induk : ', style: TextStyle(fontSize: 12)),
  //           Text('${batasWilayah.batasWilayah?.noInduk}',
  //               style: TextStyle(fontWeight: FontWeight.bold)),
  //           SizedBox(height: 5),
  //           Text('Nama : ', style: TextStyle(fontSize: 12)),
  //           Text('${batasWilayah?.batasWilayah?.nama ?? '-'}',
  //               style: TextStyle(fontWeight: FontWeight.bold)),
  //           SizedBox(height: 5),
  //           Text('Unit Kerja : ', style: TextStyle(fontSize: 12)),
  //           Text('${batasWilayah?.batasWilayah?.batasWilayah ?? '-'}',
  //               style: TextStyle(fontWeight: FontWeight.bold)),
  //           SizedBox(height: 5),
  //           Text('Jenis : ', style: TextStyle(fontSize: 12)),
  //           Text('${batasWilayah.jenis?.toUpperCase()}',
  //               style: TextStyle(fontWeight: FontWeight.bold)),
  //           SizedBox(height: 5),
  //           Text('Mulai Tangal : ', style: TextStyle(fontSize: 12)),
  //           Text('${batasWilayah.mulaiTanggal?.date}',
  //               style: TextStyle(fontWeight: FontWeight.bold)),
  //           SizedBox(height: 5),
  //           Text('Hingga Tanggal : ', style: TextStyle(fontSize: 12)),
  //           Text('${batasWilayah.sampaiTanggal?.date}',
  //               style: TextStyle(fontWeight: FontWeight.bold)),
  //           SizedBox(height: 5),
  //           Text('Keterangan : ', style: TextStyle(fontSize: 12)),
  //           Text('${batasWilayah.ket}',
  //               style: TextStyle(fontWeight: FontWeight.bold)),
  //           SizedBox(height: 5),
  //           Text('Dokumen Pendukung : ', style: TextStyle(fontSize: 12)),
  //         ];

  //         batasWilayah.dokPendukung?.forEach((foto) {
  //           children.add(Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Image.network(foto),
  //           ));
  //         });
  //         return AlertDialog(
  //           title: Text('Anda yakin ingin $status?'),
  //           content: SingleChildScrollView(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: children,
  //             ),
  //           ),
  //           actions: [
  //             MaterialButton(
  //               color: Colors.pink,
  //               child: Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Text(status.toUpperCase()),
  //               ),
  //               onPressed: () {
  //                 // updateData(status, batasWilayah);
  //               },
  //             ),
  //             TextButton(
  //               child: Text('BATAL'),
  //               onPressed: () => Navigator.of(context).pop(),
  //             ),
  //           ],
  //         );
  //       });
  // }

  // void updateData(String status, Staff batasWilayah) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();

  //     // generate absensi dilakukan jika aksi terima
  //     String pesan = "Pengusulan ${batasWilayah.jenis} anda telah ";
  //     if (status == 'terima') {
  //       pesan += ' diterima';
  //       getDaysInBeteween(batasWilayah.mulaiTanggal?.toDate(),
  //               batasWilayah.sampaiTanggal?.toDate(),
  //               selectedRadioDay: (batasWilayah.jenis == 'dinas luar')
  //                   ? RadioDay.all_day
  //                   : RadioDay.work_day)
  //           .forEach((day) {
  //         String pathDoc = DateFormat('yyyy-MM-dd').format(day);
  //         DocumentReference unitKerjaReff = FirebaseFirestore.instance
  //             .collection('presensi')
  //             .doc('${batasWilayah.uid}_${pathDoc}');

  //         print('generating absensi ${batasWilayah.uid} $pathDoc');
  //         DateTime waktuCekin = DateTime(day.year, day.month, day.day, 08, 00);
  //         DateTime waktuCekout = (batasWilayah.jenis == 'dinas luar')
  //             ? DateTime(day.year, day.month, day.day, 15, 00)
  //             : waktuCekin; // jika DL, waktu check out jam 15:00, else 08:00
  //         unitKerjaReff.set(<String, dynamic>{
  //           'check_in': <String, dynamic>{
  //             'is_mock_location': false,
  //             'location':
  //                 const GeoPoint(0.46623168996552977, 101.35609433302993),
  //             'waktu': Timestamp.fromDate(waktuCekin),
  //           },
  //           'check_out': <String, dynamic>{
  //             'is_mock_location': false,
  //             'location':
  //                 const GeoPoint(0.46623168996552977, 101.35609433302993),
  //             'waktu': Timestamp.fromDate(waktuCekout),
  //           },
  //           'is_lembur': false,
  //           'jenis': batasWilayah.jenis,
  //           'ket': batasWilayah.ket,
  //           'uid': batasWilayah.uid,
  //           'time_create': Timestamp.fromDate(
  //               waktuCekin), // kalau bisa ganti dengan waktu timestamp firebase, tapi cari kenapa diadmin yang tampil malah berdasarkan jam cekin
  //           'time_update': null,
  //           'unitKerja_id': batasWilayah.docId,
  //         });
  //       });
  //     }

  //     pesan += ' ditolak';

  //     DocumentReference unitKerjaReff = FirebaseFirestore.instance
  //         .collection('batasWilayah')
  //         .doc(batasWilayah.docId);

  //     print(unitKerjaReff);
  //     unitKerjaReff.update({
  //       'status': status,
  //     });

  //     // send notif ke pegawai/dosen
  //     bool isNotifSend = await sendNotif(
  //         [batasWilayah.batasWilayah?.playerId ?? ''],
  //         'Halo ${batasWilayah.batasWilayah?.nama}',
  //         'Usulan ${batasWilayah.jenis} anda telah di$status');
  //     print('isNotifSend : $isNotifSend');

  //     Navigator.of(context).pop();
  //   } catch (e) {
  //     alert(context: context, title: 'Perhatian!', children: [Text('$e')]);
  //   }
  // }

  DataColumn _renderCol(String label) {
    return DataColumn(
      label: Text(
        '$label',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }

  Future deleteRecord(String nama) async {
    try {
      DocumentReference ref = FirebaseFirestore.instance
          .collection(UnitKerja.collectionName)
          .doc(widget.staffSession.unitKerjaParent!.id);
      DocumentSnapshot snapshot = await ref.get();

      UnitKerja unitKerja = UnitKerja.fromJson(
          snapshot.data() as Map<String, dynamic>, snapshot.id);

      unitKerja.batasWilayah?.removeWhere((b) => b.nama == nama);

      ref.update({
        'batas_wilayah':
            unitKerja.batasWilayah?.map((b) => b.toJson()).toList() ?? [],
        'time_update': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print(e.toString());
    }
    return false;
  }
}
