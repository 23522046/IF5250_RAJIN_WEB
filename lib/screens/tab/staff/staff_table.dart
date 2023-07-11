import 'package:flutter/material.dart';
import 'package:if5250_rajin_apps_web/model/staff.dart';
import 'package:if5250_rajin_apps_web/model/unit_kerja.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'staff_form.dart';

class StaffTable extends StatefulWidget {
  final UnitKerja selectedUnitKerja;
  List<Staff> staffs;
  Staff staffSession;
  VoidCallback reloadData;

  StaffTable(
      {required this.staffs,
      required this.selectedUnitKerja,
      required this.staffSession,
      required this.reloadData,
      Key? key})
      : super(key: key);

  @override
  StaffTableState createState() => StaffTableState();
}

class StaffTableState extends State<StaffTable> {
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
                _renderCol('WAKTU REGISTRASI'),
                _renderCol('UNIT KERJA'),
                _renderCol('AKSI'),
              ],
              rows: widget.staffs.map((Staff staff) {
                _indexTable++;

                return DataRow(cells: [
                  DataCell(Text('$_indexTable')),
                  DataCell(SelectableText('${staff.noInduk}')),
                  DataCell(Text('${staff.nama}')),
                  DataCell(Text('${staff.timeCreate?.toDate()}')),
                  DataCell(Text('${widget.selectedUnitKerja.nama}')),
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
                              return StaffForm(
                                  staff: staff,
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

  // void showDialogKonfirmasi(
  //     BuildContext context, Staff staff, String status) {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         List<Widget> children = [
  //           Text('No Induk : ', style: TextStyle(fontSize: 12)),
  //           Text('${staff.staff?.noInduk}',
  //               style: TextStyle(fontWeight: FontWeight.bold)),
  //           SizedBox(height: 5),
  //           Text('Nama : ', style: TextStyle(fontSize: 12)),
  //           Text('${staff?.staff?.nama ?? '-'}',
  //               style: TextStyle(fontWeight: FontWeight.bold)),
  //           SizedBox(height: 5),
  //           Text('Unit Kerja : ', style: TextStyle(fontSize: 12)),
  //           Text('${staff?.staff?.unitKerja ?? '-'}',
  //               style: TextStyle(fontWeight: FontWeight.bold)),
  //           SizedBox(height: 5),
  //           Text('Jenis : ', style: TextStyle(fontSize: 12)),
  //           Text('${staff.jenis?.toUpperCase()}',
  //               style: TextStyle(fontWeight: FontWeight.bold)),
  //           SizedBox(height: 5),
  //           Text('Mulai Tangal : ', style: TextStyle(fontSize: 12)),
  //           Text('${staff.mulaiTanggal?.date}',
  //               style: TextStyle(fontWeight: FontWeight.bold)),
  //           SizedBox(height: 5),
  //           Text('Hingga Tanggal : ', style: TextStyle(fontSize: 12)),
  //           Text('${staff.sampaiTanggal?.date}',
  //               style: TextStyle(fontWeight: FontWeight.bold)),
  //           SizedBox(height: 5),
  //           Text('Keterangan : ', style: TextStyle(fontSize: 12)),
  //           Text('${staff.ket}',
  //               style: TextStyle(fontWeight: FontWeight.bold)),
  //           SizedBox(height: 5),
  //           Text('Dokumen Pendukung : ', style: TextStyle(fontSize: 12)),
  //         ];

  //         staff.dokPendukung?.forEach((foto) {
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
  //                 // updateData(status, staff);
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

  // void updateData(String status, Staff staff) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();

  //     // generate absensi dilakukan jika aksi terima
  //     String pesan = "Pengusulan ${staff.jenis} anda telah ";
  //     if (status == 'terima') {
  //       pesan += ' diterima';
  //       getDaysInBeteween(staff.mulaiTanggal?.toDate(),
  //               staff.sampaiTanggal?.toDate(),
  //               selectedRadioDay: (staff.jenis == 'dinas luar')
  //                   ? RadioDay.all_day
  //                   : RadioDay.work_day)
  //           .forEach((day) {
  //         String pathDoc = DateFormat('yyyy-MM-dd').format(day);
  //         DocumentReference staffReff = FirebaseFirestore.instance
  //             .collection('presensi')
  //             .doc('${staff.uid}_${pathDoc}');

  //         print('generating absensi ${staff.uid} $pathDoc');
  //         DateTime waktuCekin = DateTime(day.year, day.month, day.day, 08, 00);
  //         DateTime waktuCekout = (staff.jenis == 'dinas luar')
  //             ? DateTime(day.year, day.month, day.day, 15, 00)
  //             : waktuCekin; // jika DL, waktu check out jam 15:00, else 08:00
  //         staffReff.set(<String, dynamic>{
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
  //           'jenis': staff.jenis,
  //           'ket': staff.ket,
  //           'uid': staff.uid,
  //           'time_create': Timestamp.fromDate(
  //               waktuCekin), // kalau bisa ganti dengan waktu timestamp firebase, tapi cari kenapa diadmin yang tampil malah berdasarkan jam cekin
  //           'time_update': null,
  //           'staff_id': staff.docId,
  //         });
  //       });
  //     }

  //     pesan += ' ditolak';

  //     DocumentReference staffReff = FirebaseFirestore.instance
  //         .collection('staff')
  //         .doc(staff.docId);

  //     print(staffReff);
  //     staffReff.update({
  //       'status': status,
  //     });

  //     // send notif ke pegawai/dosen
  //     bool isNotifSend = await sendNotif(
  //         [staff.staff?.playerId ?? ''],
  //         'Halo ${staff.staff?.nama}',
  //         'Usulan ${staff.jenis} anda telah di$status');
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
}
