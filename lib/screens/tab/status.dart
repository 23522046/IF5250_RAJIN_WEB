import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../model/pengajuan.dart';
import '../../model/staff.dart';
import '../../utils/util.dart';
import '../../widgets/featured_heading.dart';
import 'status/status_table.dart';

class StatusTab extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  StatusTab({required this.scaffoldKey});
  @override
  _AbsensiTabState createState() => _AbsensiTabState();
}

class _AbsensiTabState extends State<StatusTab> {
  final _formKey = GlobalKey<FormState>();

  String? selectedUnitKerja;
  RadioDay selectedRadioDay = RadioDay.work_day;

  TextEditingController noIndukCont = TextEditingController();

  DateTime now = new DateTime.now();
  TextEditingController dateTxtContFrom = TextEditingController();
  TextEditingController dateTxtContTo = TextEditingController();
  DateTime? startDate, endDate;

  List<Pengajuan> pengajuans = [];

  Future<List<String>>? futureUnitKerja;

  void _clearForm() {
    setState(() {
      noIndukCont.text = '';
      selectedUnitKerja = null;
      dateTxtContFrom.text = '';
      dateTxtContTo.text = '';
    });
  }

  @override
  void initState() {
    super.initState();
    // futureUnitKerja = parseJsonFromAssets();
  }

  Widget _dropDownField(String label, String collectionName, String _newValue) {
    return FutureBuilder(
      future: futureUnitKerja,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error : ${snapshot.error}");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          List<String>? _listUnitKerja = snapshot.data;
          print('ada ${snapshot?.data?.length} data');
          return DropdownButtonFormField(
            value: selectedUnitKerja,
            decoration:
                InputDecoration(labelText: label, icon: Icon(Icons.work)),
            validator: (value) {
              print('value dropdown : $value');
              if (noIndukCont.text.isEmpty && value == null) {
                return "Wajib dipilih";
              }
              return null;
            },
            items: _listUnitKerja?.map((value) {
              return DropdownMenuItem(child: Text(value), value: value);
            }).toList(),
            onChanged: (value) {
              print('terpilih dropdown $label : $value');
              selectedUnitKerja = value;
            },
          );
        }

        return LinearProgressIndicator();
      },
    );
  }

  /*
  Widget _dropDownFieldFromFirestore(
      String label, String collectionName, String _newValue) {
    print('build dropdown');
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection(collectionName)
          .orderBy('nama')
          .get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Error : ${snapshot.error}");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return LinearProgressIndicator();
        }

        List<QueryDocumentSnapshot> data = snapshot.data.docs;
        print('ada ${snapshot.data.docs.length} data');
        return DropdownButtonFormField(
          // value: newValue,
          decoration: InputDecoration(labelText: label, icon: Icon(Icons.work)),
          validator: (value) {
            print('value dropdown : $value');
            if (value == null) {
              return "Wajib dipilih";
            }
            return null;
          },
          items: data.map((value) {
            String nama = value?.data()['nama'] ?? 'nama is null';

            return DropdownMenuItem(child: Text(nama), value: value);
          }).toList(),
          onChanged: (value) {
            String nama = value.data()['nama'] ?? 'nama is null';
            print('terpilih dropdown $label : $nama');
            listStaff.clear();
            listNoInduk.clear();
            selectedUnitKerja = nama;
            FirebaseFirestore.instance
                .collection('staff')
                .where('unit_kerja', isEqualTo: nama)
                .get()
                .then((snapshot) {
              print('Ada ${snapshot.docs.length} pegawai');
              if (snapshot.docs.length > 0) {
                snapshot.docs.forEach((element) {
                  Staff _staff = Staff.fromJson(element.data());
                  print('masukkan data ${_staff.nama}');
                  listStaff.add(_staff);
                  listNoInduk.add(_staff.noInduk);
                });
                listStaff.sort((a, b) => a.nama.compareTo(b.nama));
              } else {
                print(
                    'tidak ada staff pada unit kerja : ${value.data()['nama']}');
              }
            });
          },
        );
      },
    );
  }
  */

  Future<Null> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != now) {
      now = picked;
      if (isFrom) {
        dateTxtContFrom.text = formatDate(now);
        startDate = now;
        dateTxtContTo.text = dateTxtContFrom.text;
        endDate = now;
      } else {
        dateTxtContTo.text = formatDate(now);
        endDate = now;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return ListView(
      shrinkWrap: true,
      children: [
        FeaturedHeading(
          title: 'Permohonan Sakit dan Cuti',
          subtitle: '',
          screenSize: screenSize,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width / 15),
          child: SizedBox(
            width: screenSize.width,
            child: Card(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextFormField(
                              readOnly: true,
                              keyboardType: TextInputType.datetime,
                              controller: dateTxtContFrom,
                              validator: (value) {
                                if (value == null || value?.length == 0) {
                                  return "Wajib diisi";
                                }
                              },
                              decoration: const InputDecoration(
                                icon: Icon(Icons.date_range),
                                labelText: 'Dari tanggal',
                                hintText: 'Cari',
                              ),
                              onTap: () => _selectDate(context, true),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                            child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: TextFormField(
                            readOnly: true,
                            keyboardType: TextInputType.datetime,
                            controller: dateTxtContTo,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.date_range),
                              labelText: 'Hingga tanggal',
                              hintText: 'Cari',
                            ),
                            validator: (value) {
                              if (value == null || value?.length == 0) {
                                return "Wajib diisi";
                              }
                            },
                            onTap: () => _selectDate(context, false),
                          ),
                        )),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextFormField(
                              controller: noIndukCont,
                              decoration: const InputDecoration(
                                icon: Icon(Icons.format_list_numbered),
                                labelText: 'Cari berdasarkan NIP/NIK',
                              ),
                              validator: (value) {
                                if (value != null) {
                                  if (value.length > 0 && value.length < 5) {
                                    return "Minimal 5 karakter";
                                  }
                                }

                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        // Flexible(
                        //     child: _dropDownField(
                        //         'Unit Kerja', 'unit_kerja', selectedUnitKerja)),
                      ],
                    ),
                    // Text('Tampilkan Berdasarkan'),
                    // Row(
                    //   mainAxisSize: MainAxisSize.min,
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     SizedBox(width: 40),
                    //     ConstrainedBox(
                    //       constraints: BoxConstraints(maxWidth: 180),
                    //       child: RadioListTile(
                    //         title: Text('Hari Kerja'),
                    //         value: RadioDay.work_day,
                    //         onChanged: (val) {
                    //           setState(() {
                    //             selectedRadioDay = val;
                    //           });
                    //         },
                    //         groupValue: selectedRadioDay,
                    //       ),
                    //     ),
                    //     ConstrainedBox(
                    //       constraints: BoxConstraints(maxWidth: 180),
                    //       child: RadioListTile(
                    //         title: Text('Semua Hari'),
                    //         value: RadioDay.all_day,
                    //         onChanged: (val) {
                    //           setState(() {
                    //             selectedRadioDay = val;
                    //           });
                    //         },
                    //         groupValue: selectedRadioDay,
                    //       ),
                    //     ),
                    //     // Flexible(flex:2, child: Text(''))
                    //   ],
                    // ),
                    SizedBox(height: 10),
                    Center(
                      child: Row(
                        children: [
                          Expanded(
                              child: MaterialButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  pengajuans.clear();
                                });
                                if (dateTxtContFrom.text != null) {
                                  QuerySnapshot s;
                                  if (noIndukCont.text.isNotEmpty) {
                                    s = await FirebaseFirestore.instance
                                        .collection(Staff.collectionName)
                                        // .where('unit_kerja',
                                        //     isEqualTo: selectedUnitKerja)
                                        .where('is_aktif', isEqualTo: true)
                                        .where('no_induk',
                                            isEqualTo: noIndukCont.text)
                                        .get();
                                  } else {
                                    s = await FirebaseFirestore.instance
                                        .collection(Staff.collectionName)
                                        // .where('unit_kerja',
                                        //     isEqualTo: selectedUnitKerja)
                                        .where('is_aktif', isEqualTo: true)
                                        .get();
                                  }

                                  List<Staff> staffs = s.docs
                                      .map((e) => Staff.fromJson(
                                          e.data() as Map<String, dynamic>))
                                      .toList();

                                  staffs.forEach((staff) {
                                    print(staff.UID);
                                    Query queryPengajuan = FirebaseFirestore
                                        .instance
                                        .collection('pengajuan')
                                        .where('uid', isEqualTo: staff.UID)
                                        .where('time_create',
                                            isGreaterThanOrEqualTo:
                                                DateTime.parse(
                                                    dateTxtContFrom.text))
                                        .where('time_create',
                                            isLessThan: DateTime.parse(
                                                    dateTxtContTo.text)
                                                .add(new Duration(days: 1)));

                                    queryPengajuan.snapshots().listen((e) {
                                      e.docs.forEach((q) {
                                        setState(() {
                                          if (q.data() != null) {
                                            print(q.data());
                                            Pengajuan pNew = Pengajuan.fromJson(
                                                q.data()
                                                    as Map<String, dynamic>,
                                                q.id);

                                            print(pNew.docId);

                                            // jika sudah pernah dimasukkan list, maka remove agat tidak double data render
                                            if (pengajuans
                                                    .where((e) =>
                                                        e.timeCreate ==
                                                        pNew.timeCreate)
                                                    .length >
                                                0) {
                                              pengajuans.removeWhere((e) =>
                                                  e.timeCreate ==
                                                  pNew.timeCreate);
                                            }

                                            pengajuans.add(Pengajuan.fromJson(
                                                q.data()
                                                    as Map<String, dynamic>,
                                                q.id,
                                                staff: staff));
                                            print(
                                                'tambahkan ke list pengajuan atas nama ${staff.nama}');
                                          }
                                        });
                                      });
                                    });
                                  });
                                }
                              }
                            },
                            color: Colors.pinkAccent,
                            child: Text(
                              'CARI',
                              style: TextStyle(color: Colors.white),
                            ),
                          )),
                          SizedBox(width: 5),
                          Expanded(
                              child: TextButton(
                            onPressed: () => _clearForm(),
                            child: Text('RESET'),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ),
        ),
        if (startDate != null && endDate != null)
          StatusTable(
              pengajuans: pengajuans,
              startDate: startDate!,
              endDate: endDate!,
              selectedRadioDay: selectedRadioDay)
      ],
    );
  }
}
