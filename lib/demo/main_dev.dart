import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'package:latlong2/latlong.dart';

import '../models/building.dart';
import '../osm_parser.dart';
import '../screens/map_screen.dart';

List<LatLng> yuntechBoundary = [];
List<Building> campusBuildings = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final xmlContent = await rootBundle.loadString('assets/maps/map.osm');
    final parser = OsmParser(xmlContent);
    yuntechBoundary = await parser.parseBoundary('672344613');
    campusBuildings = await parser.parseBuildings();
    print("✅ 邊界載入成功，共 ${yuntechBoundary.length} 點");
    print("✅ 建築物載入成功，共 ${campusBuildings.length} 棟");
  } catch (e, stack) {
    print("❌ OSM 資料解析失敗: $e");
    print("📛 Stack trace: $stack");
  }

  runApp(const DevMapApp());
}

class DevMapApp extends StatelessWidget {
  const DevMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '地圖測試',
      debugShowCheckedModeBanner: false,
      home: MapScreen(
        boundary: yuntechBoundary,
        buildings: campusBuildings,
      ),
    );
  }
}