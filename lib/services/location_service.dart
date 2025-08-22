import 'package:geolocator/geolocator.dart';

class LocationService {
  /// 檢查並請求定位權限
  Future<bool> ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('定位服務未開啟');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('定位權限被拒絕');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('定位權限永久拒絕');
    }

    return true;
  }

  /// 取得目前位置
  Future<Position> getCurrentPosition() async {
    await ensurePermission();
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// 監聽位置變化（例如散步或鬼抓人）
  Stream<Position> getPositionStream({int distanceFilter = 5}) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: distanceFilter,
      ),
    );
  }

  /// 計算兩點間距離（單位：公尺）
  double calculateDistance({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
  }) {
    return Geolocator.distanceBetween(startLat, startLon, endLat, endLon);
  }
}