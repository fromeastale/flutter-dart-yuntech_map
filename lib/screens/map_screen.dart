import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../layers/building_layer.dart';
import '../models/building.dart';

class MapScreen extends StatelessWidget {
  final List<LatLng> boundary;
  final List<Building> buildings;
  final MapController mapController = MapController(); // ✅ 新增這行

  MapScreen({
    required this.boundary,
    required this.buildings,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('校園地圖')),
      body: FlutterMap(
        mapController: mapController, // ✅ 傳入 controller
        options: MapOptions(
          center: boundary.isNotEmpty ? boundary[0] : LatLng(23.0, 120.0),
          zoom: 16.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          if (boundary.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: boundary,
                  strokeWidth: 4.0,
                  color: Colors.blueAccent,
                ),
              ],
            ),
          if (buildings.isNotEmpty)
            BuildingLayer(
              buildings: buildings,
              mapController: mapController, // ✅ 修正這裡
            ),
        ],
      ),
    );
  }
}