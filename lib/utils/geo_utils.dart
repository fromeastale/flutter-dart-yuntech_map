import 'package:latlong2/latlong.dart';

class GeoUtils {
  /// 判斷某個點是否在多邊形內（Ray Casting 演算法）
  static bool pointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      final a = polygon[j];
      final b = polygon[j + 1];

      final latCheck = (a.latitude > point.latitude) != (b.latitude > point.latitude);
      final lonIntersect = point.longitude <
          (b.longitude - a.longitude) * (point.latitude - a.latitude) / (b.latitude - a.latitude) + a.longitude;

      if (latCheck && lonIntersect) {
        intersectCount++;
      }
    }

    return (intersectCount % 2) == 1;
  }
}