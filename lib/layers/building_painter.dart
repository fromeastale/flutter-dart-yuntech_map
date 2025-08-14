import 'dart:ui' as dart_ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../models/building.dart';

class BuildingPainter extends CustomPainter {
  final Building building;
  final MapController mapController;

  BuildingPainter({
    required this.building,
    required this.mapController,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _resolveBuildingColor(building.type).withAlpha(128) // 約等於 opacity 0.5
      ..style = PaintingStyle.fill;

    final dart_ui.Path path = dart_ui.Path();

    // ✅ 正確投影 LatLng → Offset
    final points = building.outline.map((latLng) {
      final projected = mapController.latLngToScreenPoint(latLng); // ✅ 使用正確 API
      return Offset(projected.x.toDouble(), projected.y.toDouble());
    }).toList(); // ✅ 修正拼字錯誤

    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy); // ✅ Dart:ui 的 Path 方法
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      path.close();
      canvas.drawPath(path, paint);

      // ✅ 可選：描邊
      final borderPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

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
        return Colors.grey;
    }
  }
}