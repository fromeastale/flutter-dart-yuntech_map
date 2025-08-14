import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/building.dart';
import '../layers/building_painter.dart'; 
import '../utils/geo_utils.dart';

class BuildingLayer extends StatelessWidget {
  final List<Building> buildings;
  final MapController mapController;

  const BuildingLayer({
    required this.buildings,
    required this.mapController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final validBuildings = buildings.where((b) => b.isValid).toList();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapUp: (details) {
        final tapLatLng = _offsetToLatLng(details.localPosition);
        for (final building in validBuildings) {
          if (GeoUtils.pointInPolygon(tapLatLng, building.outline)) {
              _showBuildingInfo(context, building);
            break;
          }
        }
      },
      child: Stack(
        children: [
          // ✅ 原本的 flutter_map PolygonLayer
          PolygonLayer(
            polygons: validBuildings.map((b) => Polygon(
              points: b.outline,
              color: _resolveBuildingColor(b.type).withOpacity(0.5),
              borderColor: Colors.black,
              borderStrokeWidth: 1,
            )).toList(),
          ),

          // ✅ 建築標籤
          MarkerLayer(
            markers: validBuildings.map((b) => Marker(
              point: b.center,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _resolveBuildingLabel(b),
                  style: const TextStyle(fontSize: 10, color: Colors.black),
                ),
              ),
            )).toList(),
          ),

          // ✅ 可選：使用 CustomPaint 繪製建築（更細緻控制）
          ...validBuildings.map((b) => _buildPolygon(b)),
        ],
      ),
    );
  }

  /// ✅ CustomPaint 建築繪製（可用於 hover、動畫等進階效果）
  Widget _buildPolygon(Building building) {
    return CustomPaint(
      painter: BuildingPainter(
        building: building,
        mapController: mapController,
      ),
    );
  }

  LatLng _offsetToLatLng(Offset offset) {
    return mapController.pointToLatLng(CustomPoint(offset.dx, offset.dy));
  }

  void _showBuildingInfo(BuildContext context, Building building) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(building.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('類型：${building.type.name}'),
            if (building.description != null) Text(building.description!),
          ],
        ),
      ),
    );
  }

  String _resolveBuildingLabel(Building b) {
    if (b.name.isNotEmpty) return b.name;
    if (b.tags.containsKey('name')) return b.tags['name']!;
    return '未分類建築';
  }

  Color _resolveBuildingColor(BuildingType type) {
    switch (type) {
      case BuildingType.administrative:
        return Colors.blue;
      case BuildingType.academic:
        return Colors.green;
      case BuildingType.cultural:
        return Colors.orange;
      case BuildingType.dormitory:
        return Colors.purple;
      case BuildingType.sports:
        return Colors.red;
      case BuildingType.unknown:
      default:
        return Colors.blueGrey.shade200;
    }
  }
}