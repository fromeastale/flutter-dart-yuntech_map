/*import 'package:flutter/material.dart';
import 'package:project/osm_parser.dart'; // 根據你的路徑調整
import 'package:project/main.dart'; // 引入 yuntechBoundary
import 'package:project/models/building.dart'; // ✅ 引入 Building 類別
import 'game_entry_button.dart' as dev; // ✅ 使用別名避免命名衝突
//import 'package:project/screens/three_scene.dart';
import 'package:flutter/services.dart'; // ✅ 為了使用 rootBundle

class DevHomePage extends StatefulWidget {
  const DevHomePage({super.key});

  @override
  State<DevHomePage> createState() => _DevHomePageState();
}

class _DevHomePageState extends State<DevHomePage> {
  int boundaryCount = yuntechBoundary.length;
  int buildingCount = 0;
  List<Building> campusBuildings = [];

  Future<void> reloadBoundary() async {
  try {
    final xmlContent = await rootBundle.loadString('assets/maps/map.osm');
    final parser = OsmParser(xmlContent);
    final newBoundary = await parser.parseBoundary('672344613');
    setState(() {
      yuntechBoundary = newBoundary;
      boundaryCount = newBoundary.length;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ 邊界重新載入成功，共 $boundaryCount 點")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ 邊界載入失敗: $e")),
    );
  }
}

Future<void> reloadBuildings() async {
  try {
    final xmlContent = await rootBundle.loadString('assets/maps/map.osm');
    final parser = OsmParser(xmlContent);
    final buildings = await parser.parseBuildings();
    setState(() {
      campusBuildings = buildings;
      buildingCount = buildings.length;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ 建築載入成功，共 $buildingCount 筆")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ 建築載入失敗: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    print("🛠️ DevHomePage (開發者工具頁) rendered");
    return Scaffold(
      appBar: AppBar(title: const Text("🛠️ 開發者工具頁")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("📍 目前邊界點數：$boundaryCount", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text("重新載入邊界資料"),
            onPressed: reloadBoundary,
          ),
          const SizedBox(height: 12),
          Text("🏢 建築數量：$buildingCount", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.domain),
            label: const Text("載入建築資料"),
            onPressed: reloadBuildings,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.map),
            label: const Text("前往地圖畫面"),
            onPressed: () {
              Navigator.pushNamed(context, "/map");
            },
          ),
          const Divider(height: 32),
          const Text("🎮 測試遊戲入口", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          dev.GameEntryButton(title: "Game5", routeName: "/game5"),
          dev.GameEntryButton(title: "排行榜", routeName: "/ranking"),
          dev.GameEntryButton(title: "Game5", routeName: "/game5"),
         // dev.GameEntryButton(title: "3D 測試場景", screen: const ThreeScene()), // ✅ 加上 const 只在 widget 本身支援時
        ],
      ),
    );
  }
}*/