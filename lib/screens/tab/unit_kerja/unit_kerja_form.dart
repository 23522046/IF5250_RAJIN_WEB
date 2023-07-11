import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../../../model/staff.dart';
import '../../../model/unit_kerja.dart';

class UnitKerjaForm extends StatefulWidget {
  final Staff staffSession;
  final UnitKerja? unitKerja;
  const UnitKerjaForm({super.key, required this.staffSession, this.unitKerja});

  @override
  State<UnitKerjaForm> createState() => _StaffFormState();
}

class _StaffFormState extends State<UnitKerjaForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController namaCont = TextEditingController();

  @override
  void initState() {
    if (widget.unitKerja != null) {
      namaCont.text = widget.unitKerja!.nama ?? '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.unitKerja?.nama ?? 'Tambah Unit Kerja'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                  controller: namaCont,
                  validator: (val) {
                    if (namaCont.text.isEmpty) {
                      return "Wajib diisi";
                    }
                    return null;
                  },
                  decoration:
                      const InputDecoration(labelText: 'Nama Unit Kerja')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            child: const Text('SIMPAN'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                (widget.unitKerja != null)
                    ? updateRecord()
                    : insertRecord(widget.staffSession.unitKerjaParent!.id);
                Navigator.of(context).pop();
              }
            }),
        TextButton(
            child: const Text('TUTUP'),
            onPressed: () => Navigator.of(context).pop())
      ],
    );
  }

  Future<bool> updateRecord() async {
    try {
      DocumentReference unitKerjaRef = FirebaseFirestore.instance
          .collection(UnitKerja.collectionName)
          .doc(widget.unitKerja!.idDoc);

      DocumentSnapshot unitKerja = await unitKerjaRef.get();

      if (!unitKerja.exists) {
        throw ('UnitKerja dengan kode docs : ${widget.unitKerja!.idDoc} tidak ditemukan');
      }

      unitKerjaRef.update({
        'nama': namaCont.text,
        'time_update': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print(e.toString());
    }
    return false;
  }

  Future<bool> insertRecord(String unitKerjaParentId) async {
    try {
      Query unitKerjaRef = FirebaseFirestore.instance
          .collection(UnitKerja.collectionName)
          .where('nama', isEqualTo: namaCont.text);

      QuerySnapshot unitKerja = await unitKerjaRef.get();

      if (unitKerja.docs.isNotEmpty) {
        throw ('${namaCont.text} sudah digunakan');
      }

      FirebaseFirestore.instance.collection(UnitKerja.collectionName).add({
        'nama': namaCont.text,
        'parent': FirebaseFirestore.instance
            .collection('unit_kerja')
            .doc(unitKerjaParentId),
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
