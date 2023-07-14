import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../model/staff.dart';
import '../../../model/unit_kerja.dart';
import '../../../utils/util.dart';

class OrganisasiForm extends StatefulWidget {
  final Staff staffSession;
  final UnitKerja? unitKerja;
  const OrganisasiForm({super.key, required this.staffSession, this.unitKerja});

  @override
  State<OrganisasiForm> createState() => _StaffFormState();
}

class _StaffFormState extends State<OrganisasiForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController namaInstansiCont = TextEditingController();
  TextEditingController namaUnitCont = TextEditingController();
  TextEditingController namaAdminCont = TextEditingController();
  TextEditingController noIndukCont = TextEditingController();
  TextEditingController usernamCont = TextEditingController();
  TextEditingController passCont = TextEditingController();
  TextEditingController passConfirmCont = TextEditingController();

  @override
  void initState() {
    if (widget.unitKerja != null) {
      namaInstansiCont.text = widget.unitKerja!.nama ?? '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.unitKerja?.nama ?? 'Tambah Instansi'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                  controller: namaInstansiCont,
                  validator: (val) {
                    if (namaInstansiCont.text.isEmpty) {
                      return "Wajib diisi";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      labelText:
                          'Nama Instansi, ex : Institut Teknologi Bandung')),
              if (isFormCreate)
                TextFormField(
                    controller: usernamCont,
                    validator: (val) {
                      if (usernamCont.text.isEmpty) {
                        return "Wajib diisi";
                      }
                      return null;
                    },
                    decoration:
                        const InputDecoration(labelText: 'Email Admin')),
              if (isFormCreate)
                TextFormField(
                    obscureText: true,
                    controller: passCont,
                    validator: (val) {
                      if (passCont.text.isEmpty) {
                        return "Wajib diisi";
                      }
                      return null;
                    },
                    decoration:
                        const InputDecoration(labelText: 'Password Admin')),
              if (isFormCreate)
                TextFormField(
                    obscureText: true,
                    controller: passConfirmCont,
                    validator: (val) {
                      if (passConfirmCont.text.isEmpty) {
                        return "Wajib diisi";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        labelText: 'Konfirmasi Password Admin')),
              if (isFormCreate)
                TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    controller: namaAdminCont,
                    validator: (val) {
                      if (namaAdminCont.text.isEmpty) {
                        return "Wajib diisi";
                      }
                      return null;
                    },
                    decoration:
                        const InputDecoration(labelText: 'Nama Lengkap Admin')),
              if (isFormCreate)
                TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    controller: noIndukCont,
                    validator: (val) {
                      if (noIndukCont.text.isEmpty) {
                        return "Wajib diisi";
                      }
                      return null;
                    },
                    decoration:
                        const InputDecoration(labelText: 'No Induk Admin')),
              if (isFormCreate)
                TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    controller: namaUnitCont,
                    validator: (val) {
                      if (namaUnitCont.text.isEmpty) {
                        return "Wajib diisi";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        labelText: 'Nama Unit Kerja Admin')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            child: const Text('SIMPAN'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                (widget.unitKerja != null) ? updateRecord() : insertRecord();
                Navigator.of(context).pop();
              }
            }),
        TextButton(
            child: const Text('TUTUP'),
            onPressed: () => Navigator.of(context).pop())
      ],
    );
  }

  bool get isFormCreate => widget.unitKerja == null;

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
        'nama': namaInstansiCont.text,
        'time_update': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print(e.toString());
    }
    return false;
  }

  Future<bool> insertRecord() async {
    try {
      if (passCont.text != passConfirmCont.text) {
        throw ('Kombinasi password tidak cocok');
      }
      DocumentReference docParent = await insertUnitParent();
      DocumentReference docChild = await insertUnitChild(docParent.id);
      DocumentSnapshot docChildSnap = await docChild.get();
      UnitKerja unitKerja = UnitKerja.fromJson(
          docChildSnap.data() as Map<String, dynamic>, docChildSnap.id);
      DocumentReference docStaff = await insertUserAdmin(unitKerja);
      return true;
    } catch (e) {
      alert(context: context, children: [Text('$e')]);
      return false;
    }
  }

  Future<DocumentReference> insertUnitParent() async {
    Query unitKerjaRef = FirebaseFirestore.instance
        .collection(UnitKerja.collectionName)
        .where('nama', isEqualTo: namaInstansiCont.text);

    QuerySnapshot unitKerja = await unitKerjaRef.get();

    if (unitKerja.docs.isNotEmpty) {
      throw ('${namaInstansiCont.text} sudah digunakan');
    }

    return FirebaseFirestore.instance.collection(UnitKerja.collectionName).add({
      'nama': namaInstansiCont.text,
      'time_create': FieldValue.serverTimestamp(),
      'is_aktif': true,
      'is_top_parent': true,
    });
  }

  Future<DocumentReference> insertUnitChild(String unitKerjaParentId) async {
    Query unitKerjaRef = FirebaseFirestore.instance
        .collection(UnitKerja.collectionName)
        .where('nama', isEqualTo: namaUnitCont.text);

    QuerySnapshot unitKerja = await unitKerjaRef.get();

    if (unitKerja.docs.isNotEmpty) {
      throw ('${namaUnitCont.text} sudah digunakan');
    }

    return FirebaseFirestore.instance.collection(UnitKerja.collectionName).add({
      'nama': namaUnitCont.text,
      'parent': FirebaseFirestore.instance
          .collection('unit_kerja')
          .doc(unitKerjaParentId),
      'time_create': FieldValue.serverTimestamp(),
      'is_aktif': true,
    });
  }

  Future<DocumentReference> insertUserAdmin(UnitKerja unitKerja) async {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: usernamCont.text, password: passCont.text);

    Staff staff = Staff(
        UID: userCredential.user!.uid,
        noInduk: noIndukCont.text,
        nama: namaAdminCont.text,
        unitKerja: FirebaseFirestore.instance
            .collection(UnitKerja.collectionName)
            .doc(unitKerja.idDoc),
        timeCreate: Timestamp.now(),
        isAktif: true,
        unitKerjaParentAdmin: unitKerja.parent);

    DocumentReference staffRef = FirebaseFirestore.instance
        .collection(Staff.collectionName)
        .doc(userCredential.user!.uid);

    staffRef.set(staff.toJson());
    return staffRef;
  }
}
