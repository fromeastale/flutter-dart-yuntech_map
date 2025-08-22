/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/building.dart';
import '../osm_parser.dart';
import '../main.dart'; // 提供 yuntechBoundary
import '../demo/mock_match_demo.dart';
import '../games/qte_circular_game.dart' as mini1;
import '../games/color_blind_test_game.dart' as mini2;
import '../pages/standby/standby_random_page.dart';
import '../pages/standby/standby_private_page.dart';

class UnifiedGameDevPage extends StatefulWidget {
  const UnifiedGameDevPage({super.key});

  @override
  State<UnifiedGameDevPage> createState() => _UnifiedGameDevPageState();
}

class _UnifiedGameDevPageState extends State<UnifiedGameDevPage> {
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
    return Scaffold(
      appBar: AppBar(title: const Text("🎮 遊戲與開發工具")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionCard(
            title: "🛠️ 地圖資料",
            children: [
              Text("📍 邊界點數：$boundaryCount", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("重新載入邊界"),
                onPressed: reloadBoundary,
              ),
              const SizedBox(height: 12),
              Text("🏢 建築數量：$buildingCount", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.domain),
                label: const Text("載入建築資料"),
                onPressed: reloadBuildings,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text("前往地圖畫面"),
                onPressed: () => Navigator.pushNamed(context, "/map"),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _sectionCard(
            title: "👻 鬼抓人",
            children: [
              _menuTile(
                leading: SvgPicture.asset('assets/icons/random.svg', width: 24, height: 24,
                  colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn)),
                title: '隨機房',
                onTap: () {
                  MockServer.I.createRandomRoom('me', '我');
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const StandbyRandomPage(meId: 'me', meName: '我'),
                  ));
                },
              ),
              _menuTile(
                leading: SvgPicture.asset('assets/icons/room.svg', width: 24, height: 24,
                  colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn)),
                title: '私人房',
                onTap: () async {
                  final code = await _askPrivateCode(context);
                  if (code == null) return;
                  MockServer.I.createPrivateRoom('me', '我', code);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => StandbyPrivatePage(meId: 'me', meName: '我', code: code),
                  ));
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          _sectionCard(
            title: "🎮 成就小遊戲",
            children: [
              Row(children: [
                _chipButton(label: 'QTE 成就', onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => mini1.QTECircularGame(onGameEnd: (_) => Navigator.pop(context)),
                  ));
                }),
                const SizedBox(width: 8),
                _chipButton(label: '色盲測試', onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => mini2.ColorBlindTestGame(onGameEnd: (_) => Navigator.pop(context)),
                  ));
                }),
              ]),
            ],
          ),

          const SizedBox(height: 24),
          _miniGameTestPanel(context),
        ],
      ),
    );
  }
    Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF00918E), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 12, top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(children: children),
          )
        ],
      ),
    );
  }

  Widget _menuTile({required Widget leading, required String title, required VoidCallback onTap}) {
    return Container(
      height: 64,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        minLeadingWidth: 0, leading: leading, title: Text(title),
        trailing: const Icon(Icons.chevron_right), onTap: onTap,
      ),
    );
  }

  Widget _chipButton({required String label, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFFF4F6F7), borderRadius: BorderRadius.circular(18)),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Future<String?> _askPrivateCode(BuildContext context) async {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('輸入私人房房號（4位數）'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl, keyboardType: TextInputType.number, maxLength: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(), counterText: '', hintText: '例如：0653',
            ),
            validator: (v) => (v == null || v.length != 4 || int.tryParse(v) == null)
                ? '請輸入 4 位數字' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(context, ctrl.text);
            },
            child: const Text('確認'),
          ),
        ],
      ),
    );
  }

  Widget _miniGameTestPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        const Text('測試小遊戲', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => mini1.QTECircularGame(onGameEnd: (_) => Navigator.pop(context)),
                  ),
                ),
                icon: const Icon(Icons.touch_app),
                label: const Text('QTE 圓環'),
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF00918E), shape: const StadiumBorder()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => mini2.ColorBlindTestGame(onGameEnd: (_) => Navigator.pop(context)),
                  ),
                ),
                icon: const Icon(Icons.palette_outlined),
                label: const Text('色盲測試'),
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF00918E), shape: const StadiumBorder()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text('（此區僅供開發測試，不會出現在正式版）',
            style: TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}*/