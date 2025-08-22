import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../screens/map_screen.dart';
import '../models/building.dart';

class NavPage extends StatelessWidget {
  final List<LatLng> boundary;
  final List<Building> buildings;

  const NavPage({
    required this.boundary,
    required this.buildings,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Page')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const TextField(
                  decoration: InputDecoration(
                    hintText: '輸入關鍵字地點、樓層或教室',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    FilledButton.tonal(onPressed: () {}, child: const Text('手動定位')),
                    FilledButton.tonal(onPressed: () {}, child: const Text('常用地點')),
                    FilledButton.tonalIcon(
                      onPressed: () {},
                      icon: const Icon(Icons.view_in_ar),
                      label: const Text('3D'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // ✅ 地圖區塊
          Expanded(
            child: MapScreen(
              boundary: boundary,
              buildings: [],
            ),
          ),
        ],
      ),
    );
  }
}