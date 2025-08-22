import 'package:latlong2/latlong.dart';

/// 建築類型（主要分類）
enum BuildingType {
  administrative,
  academic,
  cultural,
  dormitory,
  sports,
  unknown,
}

/// 建築資料模型
class Building {
  final String id;
  final String name;
  final List<LatLng> outline;         // 建築外框座標
  final Map<String, String> tags;     // OSM 標籤資料
  final LatLng center;                // 建築中心點
  final BuildingType type;            // 建築類型（主要分類）
  final String? description;          // 建築說明（選填）

  /// 設施類型（如廁所、ATM、飲水機等）
  final String? facilityType;         // ✅ 新增：設施分類（可選）

  Building({
    required this.id,
    required this.name,
    required this.outline,
    required this.tags,
    required this.center,
    required this.type,
    this.description,
    this.facilityType,                // ✅ 加入建構子
  });

  /// 建築是否有效（至少三點構成封閉區域）
  bool get isValid => outline.length > 2;

  /// 用於地圖標記的座標（預設使用中心點）
  LatLng get location => center;

  @override
  String toString() {
    final desc = description != null ? ' - $description' : '';
    final facility = facilityType != null ? ' [設施: $facilityType]' : '';
    return '🏢 $name (${outline.length} 點, 類型: $type)$desc$facility';
  }
}