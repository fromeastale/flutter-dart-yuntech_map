import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/building.dart';
import '../layers/map_info_panel.dart';
import '../layers/map_layer_controller.dart';

class MapScreen extends StatefulWidget {
  final List<LatLng> boundary;
  final List<Building> buildings;

  const MapScreen({
    required this.boundary,
    required this.buildings,
    super.key,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool showToilet = true, showParking = false, showAtm = false, showWater = false, showElev = false, showAccessible = true;
  final MapLayerController layerController = MapLayerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                center: widget.boundary.isNotEmpty ? widget.boundary[0] : LatLng(25.068, 121.593),
                zoom: 17.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: widget.boundary,
                      color: Colors.blue.withOpacity(0.3),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: widget.buildings.where((b) => layerController.shouldShow(b.facilityType ?? '')).map((b) => Marker(
                  point: b.location,
                  width: 40,
                  height: 40,
                  child: Icon(
                _getIconForType(b.facilityType),
                  color: _getColorForType(b.facilityType),
                  size: 32,
                  ),
                  )).toList(),
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton.small(
              child: const Icon(Icons.near_me),
              onPressed: () => _openLayerPanel(context),
            ),
          ),
        ],
      ),
    );
  }

  void _openLayerPanel(BuildContext context) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    builder: (_) => MapInfoPanel(
      controller: layerController,
      onChanged: () => setState(() {}),
    ),
  );
}

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'toilet': return Icons.wc;
      case 'atm': return Icons.account_balance;
      case 'water': return Icons.local_drink;
      case 'parking': return Icons.local_parking;
      case 'elevator': return Icons.elevator;
      case 'accessible': return Icons.accessible;
      default: return Icons.location_on;
    }
  }

  Color _getColorForType(String? type) {
    switch (type) {
      case 'toilet': return Colors.blue;
      case 'atm': return Colors.green;
      case 'water': return Colors.cyan;
      case 'parking': return Colors.orange;
      case 'elevator': return Colors.purple;
      case 'accessible': return Colors.teal;
      default: return Colors.red;
    }
  }
}