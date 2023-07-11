import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../../../model/staff.dart';
import '../../../model/unit_kerja.dart';

class StaffForm extends StatefulWidget {
  final Staff staffSession;
  final Staff? staff;
  const StaffForm({super.key, required this.staffSession, this.staff});

  @override
  State<StaffForm> createState() => _StaffFormState();
}

class _StaffFormState extends State<StaffForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController noIndukCont = TextEditingController();
  TextEditingController namaCont = TextEditingController();
  TextEditingController unitKerjaCont = TextEditingController();
  bool _isAktif = false;
  UnitKerja? selectedUnitKerja;

  @override
  void initState() {
    if (widget.staff != null) {
      noIndukCont.text = widget.staff!.noInduk ?? '';
      namaCont.text = widget.staff!.nama ?? '';
      _isAktif = widget.staff!.isAktif ?? false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.staff?.nama ?? 'Tambah Pegawai'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                  style: const TextStyle(color: Colors.black54),
                  controller: noIndukCont,
                  validator: (val) {
                    if (noIndukCont.text.isEmpty) {
                      return "Wajib diisi";
                    }
                    return null;
                  },
                  readOnly: (widget.staff != null) ? true : false,
                  decoration: const InputDecoration(labelText: 'Nomor Induk')),
              TextFormField(
                  controller: namaCont,
                  validator: (val) {
                    if (namaCont.text.isEmpty) {
                      return "Wajib diisi";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Nama Pegawai')),
              _dropDownField('Unit Kerja', selectedUnitKerja,
                  widget.staffSession.unitKerjaParent!.id),
              if (widget.staff != null)
                CheckboxListTile(
                    title: const Text('Aktif'),
                    subtitle: const Text('Ceklis jika pegawai masih aktif'),
                    value: _isAktif,
                    onChanged: (val) {
                      setState(() {
                        _isAktif = val!;
                      });
                    })
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            child: const Text('SIMPAN'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                (widget.staff != null) ? updateRecord() : insertRecord();
                Navigator.of(context).pop();
              }
            }),
        TextButton(
            child: const Text('TUTUP'),
            onPressed: () => Navigator.of(context).pop())
      ],
    );
  }

  Widget _dropDownField(
      String label, UnitKerja? newValue, String idParentUnitKerja) {
    return FutureBuilder(
      // future: parseJsonFromAssets(),
      future: FirebaseFirestore.instance
          .collection('unit_kerja')
          .where('parent',
              isEqualTo: FirebaseFirestore.instance
                  .collection('unit_kerja')
                  .doc(idParentUnitKerja))
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error : ${snapshot.error}");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          if (!snapshot.hasData) return const Text('Tidak ada data');
          List<UnitKerja> listUnitKerja = snapshot.data!.docs
              .map((d) => UnitKerja.fromJson(d.data(), d.id))
              .toList();

          return DropdownButtonFormField(
            // TODO: ini kalo diaktifkan error duplikat items di dropdown tapi belum tahu kenapa?
            // value: newValue,
            decoration:
                InputDecoration(labelText: label, icon: Icon(Icons.work)),
            validator: (value) {
              // print('value dropdown : $value');
              if (selectedUnitKerja == null) {
                return "Wajib dipilih";
              }
              return null;
            },
            items: listUnitKerja.map((value) {
              return DropdownMenuItem(child: Text(value.nama!), value: value);
            }).toList(),
            onChanged: (value) {
              // print('terpilih dropdown $label : $value');
              selectedUnitKerja = value;
            },
          );
        }

        return const LinearProgressIndicator();
      },
    );
  }

  Future<bool> updateRecord() async {
    try {
      DocumentReference staffReff = FirebaseFirestore.instance
          .collection(Staff.collectionName)
          .doc(widget.staff!.UID);

      DocumentSnapshot presensi = await staffReff.get();

      if (!presensi.exists) {
        throw ('Staff dengan kode docs : ${widget.staff!.UID} tidak ditemukan');
      }

      staffReff.update({
        'nama': namaCont.text,
        'no_induk': noIndukCont.text,
        'unit_kerja': FirebaseFirestore.instance
            .collection('unit_kerja')
            .doc(selectedUnitKerja!.idDoc),
        'time_update': FieldValue.serverTimestamp(),
        'is_aktif': _isAktif
      });
      return true;
    } catch (e) {
      print(e.toString());
    }
    return false;
  }

  Future<bool> insertRecord() async {
    try {
      DocumentReference staffReff = FirebaseFirestore.instance
          .collection(Staff.collectionName)
          .doc(noIndukCont.text);

      DocumentSnapshot presensi = await staffReff.get();

      if (presensi.exists) {
        throw ('No Induk : ${noIndukCont.text} sudah digunakan');
      }

      staffReff.set({
        'nama': namaCont.text,
        'no_induk': noIndukCont.text,
        'unit_kerja': FirebaseFirestore.instance
            .collection('unit_kerja')
            .doc(selectedUnitKerja!.idDoc),
        'time_create': FieldValue.serverTimestamp(),
        'is_aktif': true,
      });
      return true;
    } catch (e) {
      print(e.toString());
    }
    return false;
  }
}
