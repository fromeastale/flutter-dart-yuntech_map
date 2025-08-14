import 'package:latlong2/latlong.dart';

enum BuildingType {
  administrative,
  academic,
  cultural,
  dormitory,
  sports,
  unknown,
}

class Building {
  final String id;
  final String name;
  final List<LatLng> outline;
  final Map<String, String> tags;
  final LatLng center;
  final BuildingType type;
  final String? description; // ✅ 新增欄位

  Building({
    required this.id,
    required this.name,
    required this.outline,
    required this.tags,
    required this.center,
    required this.type,
    this.description, // ✅ 加入建構子
  });

  @override
  String toString() {
    final desc = description != null ? ' - $description' : '';
    return '🏢 $name (${outline.length} 點, 類型: $type)$desc';
  }

  bool get isValid => outline.length > 2;
}