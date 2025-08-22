import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:latlong2/latlong.dart';
import 'package:project/demo/game_dev_page.dart';

// 📦 模型與解析器
import 'models/building.dart';
import 'osm_parser.dart';

// 📥 畫面導入
import 'screens/map_screen.dart' as screen;
import 'games/game5.dart';
import 'games/game6.dart';
import 'games/game9.dart';

// 🧩 分頁元件
import 'pages/home_page.dart';
import 'pages/nav_page.dart';
/*import 'pages/unified_game_dev_page.dart';*/
import 'pages/game_page.dart';
import 'pages/info_page.dart';

// 🌐 全域資料（可改為 Provider 管理）
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

  runZonedGuarded(() {
    runApp(CampusApp(
      boundary: yuntechBoundary,
      buildings: campusBuildings,
    ));
  }, (error, stackTrace) {
    print("❌ App crash: $error");
    print("📛 Stack trace: $stackTrace");
  });
}

class CampusApp extends StatelessWidget {
  final List<LatLng> boundary;
  final List<Building> buildings;

  const CampusApp({
    required this.boundary,
    required this.buildings,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF00918E);

    return MaterialApp(
      title: '校園鬼抓人',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: primaryColor.withOpacity(0.15),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
            (states) => TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: states.contains(WidgetState.selected)
                  ? primaryColor
                  : Colors.grey[700],
            ),
          ),
          height: 70,
        ),
      ),
      home: _RootTabs(boundary: boundary, buildings: buildings),
      routes: {
        '/dev': (context) => const DevHomePage(),
       // '/game_dev': (context) => const GameDevPage(),
        '/map': (context) => screen.MapScreen(
              boundary: boundary,
              buildings: buildings,
            ),
        '/game5': (context) => const Game5(),
        '/game6': (context) => const Game6(),
        '/game9': (context) => const Game9(),
      },
    );
  }
}

class _RootTabs extends StatefulWidget {
  final List<LatLng> boundary;
  final List<Building> buildings;

  const _RootTabs({
    required this.boundary,
    required this.buildings,
  });

  @override
  State<_RootTabs> createState() => _RootTabsState();
}

class _RootTabsState extends State<_RootTabs> {
  int _index = 2;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(boundary: widget.boundary, buildings: widget.buildings),
      NavPage(boundary: yuntechBoundary, buildings: campusBuildings),
      const GamePage(),
      const InfoPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final primaryColor = cs.primary;

    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: _svgIcon('assets/icons/home.svg', Colors.grey[700]!),
            selectedIcon: _svgIcon('assets/icons/home.svg', primaryColor),
            label: '首頁',
          ),
          NavigationDestination(
            icon: _svgIcon('assets/icons/nav.svg', Colors.grey[700]!),
            selectedIcon: _svgIcon('assets/icons/nav.svg', primaryColor),
            label: '導航',
          ),
          NavigationDestination(
            icon: _svgIcon('assets/icons/game.svg', Colors.grey[700]!),
            selectedIcon: _svgIcon('assets/icons/game.svg', primaryColor),
            label: '遊戲',
          ),
          NavigationDestination(
            icon: _svgIcon('assets/icons/info.svg', Colors.grey[700]!),
            selectedIcon: _svgIcon('assets/icons/info.svg', primaryColor),
            label: '個資',
          ),
        ],
      ),
    );
  }

  Widget _svgIcon(String path, Color color, {double size = 24}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

class DevHomePage extends StatelessWidget {
  const DevHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("遊戲測試入口")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          GameEntryButton(title: "Game5", screen: Game5()),
          GameEntryButton(title: "Game6", screen: Game6()),
          GameEntryButton(title: "Game9", screen: Game9()),
        ],
      ),
    );
  }
}

class GameEntryButton extends StatelessWidget {
  final String title;
  final Widget screen;
  const GameEntryButton({required this.title, required this.screen, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        child: Text(title),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        },
      ),
    );
  }
}