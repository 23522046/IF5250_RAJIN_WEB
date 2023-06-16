import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../model/staff.dart';
import '../../model/staff_presensi.dart';
import '../../utils/session.dart';
import '../../utils/util.dart';
import '../../widgets/featured_heading.dart';
import 'absensi/absensi_table.dart';

GlobalKey<AbsensiTableState> globalKey = GlobalKey();

class AbsensiTab extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  AbsensiTab({required this.scaffoldKey});
  @override
  _AbsensiTabState createState() => _AbsensiTabState();
}

class _AbsensiTabState extends State<AbsensiTab> {
  final _formKey = GlobalKey<FormState>();
  Query? queryPresensi;

  String? selectedUnitKerja;
  RadioDay selectedRadioDay = RadioDay.work_day;

  TextEditingController noIndukCont = TextEditingController();
  TextEditingController namaCont = TextEditingController();

  DateTime now = new DateTime.now();
  TextEditingController dateTxtContFrom = TextEditingController();
  TextEditingController dateTxtContTo = TextEditingController();
  DateTime? startDate, endDate;
  List<Staff> listStaff = <Staff>[];
  List<String> listNoInduk = <String>[];
  List<StaffPresensi> staffPresensis = <StaffPresensi>[];

  void _clearForm() {
    setState(() {
      noIndukCont.text = '';
      namaCont.text = '';
      selectedUnitKerja = null;
      dateTxtContFrom.text = '';
      dateTxtContTo.text = '';
      listStaff.clear();
      listNoInduk.clear();
      staffPresensis.clear();
    });
  }

  Widget _dropDownField(String label, String collectionName, String _newValue) {
    return FutureBuilder(
      // future: parseJsonFromAssets(),
      future: null,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error : ${snapshot.error}");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          List<String> _listUnitKerja = snapshot.data as List<String>;

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
            items: _listUnitKerja.map((value) {
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

  void showDialogCreate() {
    // showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (context) {
    //       return CreatePage();
    //       // return CreatePtipdPage();
    //     });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FutureBuilder(
          future: loadSession(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('${snapshot.error}');
            } else if (snapshot.connectionState == ConnectionState.done) {
              Staff s = snapshot.data as Staff;
              return (s.isAdminSistem)
                  ? FloatingActionButton(
                      child: Icon(Icons.add),
                      onPressed: () => showDialogCreate())
                  : Text('');
            }

            return CircularProgressIndicator();
          }),
      body: ListView(
        shrinkWrap: true,
        children: [
          FeaturedHeading(
            title: 'Laporan Kehadiran Pegawai',
            screenSize: screenSize,
            subtitle: '',
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: screenSize.width / 15),
              child: Text(
                'Gunakan filter untuk mencari presensi',
                style: TextStyle(fontStyle: FontStyle.italic),
              )),
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
                                  if (value == null || value.length == 0) {
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
                                if (value == null || value.length == 0) {
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
                          //     child: _dropDownField('Unit Kerja', 'unit_kerja',
                          //         selectedUnitKerja)),
                        ],
                      ),
                      // Text('Tampilkan Berdasarkan'),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 40),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 180),
                            child: RadioListTile(
                              title: Text('Hari Kerja'),
                              value: RadioDay.work_day,
                              onChanged: (val) {
                                setState(() {
                                  selectedRadioDay = val!;
                                });
                              },
                              groupValue: selectedRadioDay,
                            ),
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 180),
                            child: RadioListTile(
                              title: Text('Semua Hari'),
                              value: RadioDay.all_day,
                              onChanged: (val) {
                                setState(() {
                                  selectedRadioDay = val!;
                                });
                              },
                              groupValue: selectedRadioDay,
                            ),
                          ),
                          // ConstrainedBox(
                          //   constraints: BoxConstraints(maxWidth: 180),
                          //   child: RadioListTile(
                          //     title: Text('Hanya Lembur'),
                          //     value: RadioDay.overtime_only,
                          //     onChanged: (val) {
                          //       setState(() {
                          //         selectedRadioDay = val;
                          //       });
                          //     },
                          //     groupValue: selectedRadioDay,
                          //   ),
                          // ),
                          // Flexible(flex:2, child: Text(''))
                        ],
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Row(
                          children: [
                            Expanded(
                                child: MaterialButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  if (dateTxtContFrom.text != null) {
                                    // kosongkan listStaff dan listNoInduk
                                    setState(() {
                                      listStaff.clear();
                                      listNoInduk.clear();
                                      print(
                                          'listStaff.length : ${listStaff.length}; listNoInduk.length : ${listNoInduk.length}');
                                    });

                                    // fetch data master staff berdasarkan unit kerja
                                    Query queryStaff;
                                    CollectionReference ref = FirebaseFirestore
                                        .instance
                                        .collection('staff');
                                    // Jika kolom cari berdasarkan nip/nik berisi
                                    if (noIndukCont.text.length > 0) {
                                      queryStaff = ref.where('no_induk',
                                          isEqualTo: noIndukCont.text);
                                      print(
                                          'cari staff berdasarkan no_induk : ${noIndukCont.text}');

                                      // jika administrator unit kerja, maka yang dicari hanya boleh staff unit tersebut
                                      Staff session = await loadSession();
                                      if (session.isAdminUnit) {
                                        queryStaff = queryStaff.where(
                                            'unit_kerja',
                                            isEqualTo: session.unitKerja);
                                      }
                                    } else {
                                      // Jika dropdown unit kerja berisi
                                      queryStaff = ref.where('unit_kerja',
                                          isEqualTo: selectedUnitKerja);
                                      print(
                                          'cari staff berdasarkan unit_kerja : $selectedUnitKerja');
                                    }

                                    queryStaff
                                        .where('is_aktif', isEqualTo: true)
                                        .get()
                                        .then((snapshot) {
                                      print(
                                          'Ada ${snapshot.docs.length} pegawai');
                                      if (snapshot.docs.length > 0) {
                                        snapshot.docs.forEach((element) {
                                          Staff _staff = Staff.fromJson(element
                                              .data() as Map<String, dynamic>);
                                          print('masukkan data ${_staff.nama}');
                                          listStaff.add(_staff);
                                          listNoInduk.add(_staff.noInduk!);
                                        });
                                        setState(() {
                                          listStaff.sort((a, b) =>
                                              a.nama!.compareTo(b.nama!));
                                        });
                                      } else {
                                        print(
                                            'tidak ada staff pada unit kerja : $selectedUnitKerja');
                                      }
                                    });
                                    // end of fetch data master staff

                                    queryPresensi = FirebaseFirestore.instance
                                        .collection('presensi');

                                    queryPresensi = queryPresensi!
                                        .where('check_in.waktu',
                                            isGreaterThanOrEqualTo:
                                                DateTime.parse(
                                                    dateTxtContFrom.text))
                                        .where('check_in.waktu',
                                            isLessThan: DateTime.parse(
                                                    dateTxtContTo.text)
                                                .add(new Duration(days: 1)));

                                    setState(() {
                                      queryPresensi = queryPresensi;
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
                      SizedBox(height: 5),
                      Row(
                        children: [
                          // FITUR INI DIPINDAHKAN KE MENU BARU YAITU LAPORAN BULANAN
                          // Expanded(
                          //     child: FlatButton(
                          //   color: Colors.greenAccent,
                          //   onPressed: (listStaff.isNotEmpty)
                          //       ? () => globalKey.currentState.methodA()
                          //       : null,
                          //   child: Text('EXPORT PDF'),
                          // )),
                          // SizedBox(width: 5),
                          Expanded(
                              child: MaterialButton(
                            color: Colors.blueAccent,
                            onPressed: (listStaff.isNotEmpty)
                                ?
                                //() => globalKey.currentState.methodB()
                                null
                                : null,
                            child: Text(
                              'EXPORT HASIL',
                              style: TextStyle(color: Colors.white),
                            ),
                          ))
                        ],
                      ),
                    ],
                  ),
                ),
              )),
            ),
          ),
          if (queryPresensi != null)
            AbsensiTable(
                queryPresensi: queryPresensi!,
                listStaff: listStaff,
                startDate: startDate,
                endDate: endDate,
                selectedRadioDay: selectedRadioDay,
                key: globalKey)
        ],
      ),
    );
  }

  Future<List<Staff>> getSuggestionsStaff(String pattern) async {
    Dio dio = new Dio();
    List<Staff> staffs = [];

    try {
      final res = await dio.get(
          'https://presensia.uin-suska.ac.id/api/pegawai/search.php?q=$pattern');

      // print(res.data['data']);

      if (res.statusCode == 200 &&
          res.data['code'] == 200 &&
          res.data['data'] != null) {
        staffs = res.data['data']
            .map<Staff>((d) => Staff(noInduk: d['nip'], nama: d['nma']))
            .toList();
      }
    } catch (e) {
      print('error damn');
      print(e);
    }

    // List<String> data = res.data
    return staffs;
  }
}
