import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:if5250_rajin_apps_web/utils/util.dart';
import 'package:intl/intl.dart';

import '../../../model/presensi.dart';
import '../../../model/staff.dart';
import '../../../utils/session.dart';

class DetailPage extends StatefulWidget {
  final Presensi presensi;
  final Staff staff;

  DetailPage({required this.presensi, required this.staff});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String text = 'Hello';
  late String? selectedStatus;

  TextEditingController noIndukCont = TextEditingController();
  TextEditingController jamMasukCont = TextEditingController();
  TextEditingController jamPulangCont = TextEditingController();
  TextEditingController ketCont = TextEditingController();

  @override
  void initState() {
    selectedStatus = widget.presensi.jenis;
    noIndukCont.text = widget.presensi.staffId ?? '';
    jamMasukCont.text = DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(widget.presensi.checkIn.waktu.toDate());
    jamPulangCont.text = (widget.presensi.checkOut != null)
        ? DateFormat('yyyy-MM-dd HH:mm:ss')
            .format(widget.presensi.checkOut!.waktu.toDate())
        : '';
    ketCont.text = widget.presensi.ket!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.presensi.timeCreate.date}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
                style: TextStyle(color: Colors.black54),
                initialValue: widget.staff.nama,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Nama Pegawai')),
            TextFormField(
                style: TextStyle(color: Colors.black54),
                controller: noIndukCont,
                readOnly: true,
                decoration: InputDecoration(labelText: 'NIP/NIK')),
            DropdownButtonFormField(
              onChanged: (val) {
                setState(() {
                  selectedStatus = val;
                });
              },
              decoration: InputDecoration(labelText: 'Kegiatan'),
              value: widget.presensi.jenis,
              items: [
                DropdownMenuItem(child: Text('WFO'), value: 'wfo'),
                DropdownMenuItem(child: Text('WFH'), value: 'wfh'),
                DropdownMenuItem(
                    child: Text('Dinas Luar'), value: 'dinas luar'),
                DropdownMenuItem(child: Text('Cuti'), value: 'cuti'),
                DropdownMenuItem(child: Text('Sakit'), value: 'sakit'),
              ],
            ),
            if (widget.presensi.jenis != 'wfh' ||
                widget.presensi.jenis != 'wfo')
              TextFormField(
                  // style: TextStyle(color: Colors.black54),
                  controller: ketCont,
                  readOnly: false,
                  decoration: InputDecoration(labelText: 'Keterangan')),
            Row(children: [
              Expanded(
                child: TextFormField(
                    controller: jamMasukCont,
                    readOnly: false,
                    decoration: InputDecoration(labelText: 'Jam Masuk')),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                    controller: jamPulangCont,
                    readOnly: false,
                    decoration: InputDecoration(labelText: 'Jam Pulang')),
              )
            ]),
          ],
        ),
      ),
      actions: [
        TextButton(
            child: Text('SIMPAN'),
            onPressed: () {
              updateRecord();
            }),
        TextButton(
            child: Text('TUTUP'), onPressed: () => Navigator.of(context).pop())
      ],
    );
  }

  void updateRecord() async {
    try {
      Staff s = await loadSession();
      // jika tanggal jam masuk dan jam berubah tidak sama
      if (!widget.presensi.checkIn.waktu
          .toDate()
          .isSameDate(DateTime.parse(jamMasukCont.text))) {
        throw Exception('Tanggal jam masuk tidak sesuai');
      }

      if (jamPulangCont.text.isNotEmpty) {
        // jika tanggal jam keluar dan jam masuk beda
        if (!DateTime.parse(jamMasukCont.text)
            .isSameDate(DateTime.parse(jamPulangCont.text))) {
          throw Exception('Tanggal jam masuk dan jam pulang tidak sama');
        }
      }

      String tanggalPres = DateFormat('yyyy-MM-dd')
          .format(widget.presensi.checkIn.waktu.toDate());
      String idDoc = '${noIndukCont.text}_${tanggalPres}';
      DocumentReference presensiReff =
          FirebaseFirestore.instance.collection('presensi').doc(idDoc);

      DocumentSnapshot presensi = await presensiReff.get();

      if (!presensi.exists) {
        throw ('Presensi dengan kode docs : $idDoc tidak ditemukan');
      }

      Map<String, dynamic> checkIn = {
        'is_mock_location': widget.presensi.checkIn.isMockLocation,
        'location': GeoPoint(widget.presensi.checkIn.location.latitude,
            widget.presensi.checkIn.location.longitude),
        'waktu': Timestamp.fromDate(DateTime.parse(jamMasukCont.text))
      };

      Map<String, dynamic>? checkOut = (jamPulangCont.text.isNotEmpty)
          ? {
              'device_info': null,
              'is_mock_location': false,
              'location': GeoPoint(0.46623168996552977, 101.35609433302993),
              'waktu': Timestamp.fromDate(DateTime.parse(jamPulangCont.text))
            }
          : null;

      Presensi p = Presensi.fromJson(presensi.data() as Map<String, dynamic>);

      presensiReff.update({
        'jenis': selectedStatus,
        'check_out': checkOut,
        'check_in': checkIn,
        'is_lembur': widget.presensi.isLembur,
        'ket': ketCont.text,
        'time_update': FieldValue.serverTimestamp(),
        'is_edited': true,
      });
      Navigator.of(context).pop();
    } catch (e) {
      alert(context: context, children: [Text(e.toString())]);
    }
  }
}
