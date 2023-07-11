import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:if5250_rajin_apps_web/model/batas_wilayah.dart';
import 'package:if5250_rajin_apps_web/model/staff.dart';
import 'package:if5250_rajin_apps_web/model/unit_kerja.dart';
import 'package:if5250_rajin_apps_web/screens/tab/batas_wilayah/form/wilayah_table.dart';
import 'package:if5250_rajin_apps_web/utils/util.dart';

class BatasWilayahSetPolygon extends StatefulWidget {
  final BatasWilayah? wilayah;
  final Staff staffSession;
  BatasWilayahSetPolygon({super.key, this.wilayah, required this.staffSession});

  @override
  State<BatasWilayahSetPolygon> createState() => _BatasWilayahSetPolygonState();
}

class _BatasWilayahSetPolygonState extends State<BatasWilayahSetPolygon> {
  late GoogleMapController mapController;
  TextEditingController namaCont = TextEditingController();

  late LatLng _center;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  final Set<Marker> _markers = {};
  final Set<Polygon> _polygons = {};
  int _idMarker = 0;

  @override
  void initState() {
    _center = (widget.wilayah?.polygons != null)
        ? LatLng(widget.wilayah!.polygons![0].latitude,
            widget.wilayah!.polygons![0].longitude)
        : const LatLng(-6.890309512323422, 107.6102700754384);
    widget.wilayah?.polygons?.forEach((p) {
      addMarker(LatLng(p.latitude, p.longitude));
    });
    drawPolygon();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wilayah?.nama ?? 'Tambah Wilayah Baru'),
        backgroundColor: Colors.green[700],
      ),
      floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.check),
          label: const Text('Simpan'),
          onPressed: () async {
            if (namaCont.text.isEmpty) {
              return alert(
                  context: context,
                  children: [const Text('Nama wilayah tidak boleh kosong')]);
            }

            if (_markers.isEmpty) {
              return alert(context: context, children: [
                const Text('Poligon batas wilayah tidak boleh kosong')
              ]);
            }
            updateDB().then((res) {
              if (res) {
                return Navigator.of(context).pop(res);
              }
              alert(
                  context: context,
                  children: [const Text('Terjadi kesalahan')]);
            });
          }),
      body: Column(
        children: [
          Flexible(
              flex: 3,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 16.0,
                ),
                markers: _markers,
                polygons: _polygons,
                onTap: (position) {
                  addMarker(position);
                  drawPolygon();
                },
              )),
          Flexible(
              flex: 1,
              child: WilayahTable(
                namaCont: namaCont,
                batasWilayah: widget.wilayah,
                staffSession: widget.staffSession,
                drawPolygonFunc: () => drawPolygon(),
                clearMapsFunc: () => clearMaps(),
              ))
        ],
      ),
    );
  }

  void drawPolygon() {
    setState(() {
      _polygons.clear();
    });

    var markerList = _markers
        .map((m) => Marker(markerId: m.markerId, position: m.position))
        .toList();

    markerList.sort((a, b) => a.markerId.value.compareTo(b.markerId.value));

    List<LatLng> points = markerList
        .map((m) => LatLng(m.position.latitude, m.position.longitude))
        .toList();

    Polygon p = Polygon(
      // given polygonId
      polygonId: const PolygonId('1'),
      // initialize the list of points to display polygon
      points: points,
      // given color to polygon
      fillColor: Colors.red.withOpacity(0.3),
      // given border color to polygon
      strokeColor: Colors.red,
      geodesic: true,
      // given width of border
      strokeWidth: 4,
    );

    setState(() {
      _polygons.add(p);
    });
  }

  void addMarker(LatLng position, {int? idMarker}) {
    int id = idMarker ?? _idMarker++;
    Marker m = Marker(
        markerId: MarkerId('$id'),
        draggable: true,
        position: position,
        onTap: () {
          Marker m = findMarker(id);
          removeMarker(m);
          drawPolygon();
        },
        onDragEnd: ((newPosition) {
          Marker m = findMarker(id);
          removeMarker(m);
          addMarker(LatLng(newPosition.latitude, newPosition.longitude),
              idMarker: id);
          drawPolygon();
        }));

    setState(() {
      _markers.add(m);
    });
  }

  void removeMarker(Marker m) {
    setState(() {
      _markers.remove(m);
    });
  }

  void clearMaps() {
    setState(() {
      _markers.clear();
      _polygons.clear();
    });
  }

  Marker findMarker(int id) {
    return _markers.firstWhere((marker) => marker.markerId.value == '$id');
  }

  Future<bool> updateDB() async {
    String unitKerjaParentId = widget.staffSession.unitKerjaParent!.id;
    if (widget.wilayah == null) {
      return await insertRecord(unitKerjaParentId);
    } else {
      return await updateRecord(unitKerjaParentId, widget.wilayah!);
    }
  }

  Future<bool> insertRecord(String unitKerjaParentId) async {
    try {
      DocumentReference ref = FirebaseFirestore.instance
          .collection(UnitKerja.collectionName)
          .doc(unitKerjaParentId);
      DocumentSnapshot snapshot = await ref.get();

      UnitKerja unitKerja = UnitKerja.fromJson(
          snapshot.data() as Map<String, dynamic>, snapshot.id);

      List<BatasWilayah> listBatasWilayah = unitKerja.batasWilayah ?? [];

      BatasWilayah batasWilayah = BatasWilayah(
          nama: namaCont.text,
          polygons: _markers
              .map((m) => GeoPoint(m.position.latitude, m.position.longitude))
              .toList());

      listBatasWilayah.add(batasWilayah);

      ref.update({
        'batas_wilayah': listBatasWilayah.map((b) => b.toJson()).toList(),
        'time_update': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print(e.toString());
    }
    return false;
  }

  Future<bool> updateRecord(
      String unitKerjaParentId, BatasWilayah wilayah) async {
    try {
      DocumentReference ref = FirebaseFirestore.instance
          .collection(UnitKerja.collectionName)
          .doc(unitKerjaParentId);
      DocumentSnapshot snapshot = await ref.get();

      UnitKerja unitKerja = UnitKerja.fromJson(
          snapshot.data() as Map<String, dynamic>, snapshot.id);

      List<BatasWilayah> listBatasWilayah = unitKerja.batasWilayah ?? [];

      listBatasWilayah.removeWhere((b) => b.nama == wilayah.nama);

      BatasWilayah batasWilayah = BatasWilayah(
          nama: namaCont.text,
          polygons: _markers
              .map((m) => GeoPoint(m.position.latitude, m.position.longitude))
              .toList());

      listBatasWilayah.add(batasWilayah);

      ref.update({
        'batas_wilayah': listBatasWilayah.map((b) => b.toJson()).toList(),
        'time_update': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print(e.toString());
    }
    return false;
  }
}
