import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

int calcHuntersForTotalPlayers(int total) {
  if (total < 4) return 0;
  for (int g = 1; g < 20; g++) {
    final s = total - g;
    final low = 3 + 4 * (g - 1);
    final high = 6 + 4 * (g - 1);
    if (s >= low && s <= high) return g;
  }
  int g = 1;
  while (true) {
    final high = 6 + 4 * (g - 1);
    if (total - g <= high) return g;
    g++;
  }
}

enum RoomType { random, private }
enum RoomStatus { lobby, assigning, playing }
enum Role { tbd, student, hunter }

class Player {
  final String id;
  String name;
  bool ready;
  Role role;        // 實際分配
  Role pickedRole;  // 私人房自選
  Player({
    required this.id,
    required this.name,
    this.ready = false,
    this.role = Role.tbd,
    this.pickedRole = Role.tbd,
  });
}

class Room {
  final RoomType type;
  String code;
  String hostId;
  RoomStatus status;
  int durationSec;
  final List<Player> players;
  Room({
    required this.type,
    required this.players,
    this.code = '',
    this.hostId = '',
    this.status = RoomStatus.lobby,
    this.durationSec = 20 * 60,
  });
}

class MockServer {
  static final MockServer I = MockServer._();
  MockServer._();

  Room? room;

  void createRandomRoom(String meId, String meName) {
    room = Room(type: RoomType.random, players: [
      Player(id: meId, name: meName),
    ]);
  }

  void createPrivateRoom(String meId, String meName, String code) {
    room = Room(
      type: RoomType.private,
      code: code,
      hostId: meId,
      players: [Player(id: meId, name: meName)],
    );
  }

  void addBot() {
    if (room == null) return;
    final id = 'bot_${room!.players.length + 1}';
    room!.players.add(Player(id: id, name: '玩家$id'));
  }

  void removeBot() {
    if (room == null) return;
    final idx = room!.players.lastIndexWhere((p) => p.id.startsWith('bot_'));
    if (idx >= 0) room!.players.removeAt(idx);
  }

  void toggleReady(String uid, bool ready) {
    room?.players.firstWhere((p) => p.id == uid).ready = ready;
  }

  void pickRole(String uid, Role role) {
    room?.players.firstWhere((p) => p.id == uid).pickedRole = role;
  }

  /// 隨機房：全員準備且人數≥4 → 隨機抽鬼
  void startRandomAssign() {
    final r = room!;
    final allReady = r.players.isNotEmpty && r.players.every((p) => p.ready);
    if (!allReady || r.players.length < 4) return;

    r.status = RoomStatus.assigning;
    final total = r.players.length;
    final needHunters = calcHuntersForTotalPlayers(total);

    final rnd = Random();
    final shuffled = [...r.players]..shuffle(rnd);
    final hunters = shuffled.take(needHunters).toSet();
    for (final p in r.players) {
      p.role = hunters.contains(p) ? Role.hunter : Role.student;
    }
    r.status = RoomStatus.playing;
  }

  /// 房主一鍵隨機分配（私人房）：更新 pickedRole，並把 ready 清掉
  void randomizePrivatePicks() {
    final r = room!;
    final total = r.players.length;
    if (total < 4) return;

    final needHunters = calcHuntersForTotalPlayers(total);
    final rnd = Random();
    final shuffled = [...r.players]..shuffle(rnd);

    for (final p in r.players) {
      p.pickedRole = Role.tbd;
      p.ready = false;
    }
    for (int i = 0; i < needHunters && i < shuffled.length; i++) {
      shuffled[i].pickedRole = Role.hunter;
    }
    for (int i = needHunters; i < shuffled.length; i++) {
      shuffled[i].pickedRole = Role.student;
    }
  }

  /// 私人房：房主開始 → 鬼數正確；未分配者維持 tbd（等待頁會讓他退回）
  String? startPrivateByHost(String hostId) {
    final r = room!;
    if (r.hostId != hostId) return '只有房主可以開始';
    if (r.players.length < 4) return '至少需要 4 位玩家';

    final hunters = r.players.where((p) => p.pickedRole == Role.hunter).toList();
    final needHunters = calcHuntersForTotalPlayers(r.players.length);
    if (hunters.length != needHunters) {
      return '鬼的數量須為 $needHunters 人（目前 ${hunters.length} 人）';
    }

    r.status = RoomStatus.assigning;
    for (final p in r.players) {
      if (p.pickedRole == Role.hunter) {
        p.role = Role.hunter;
      } else if (p.pickedRole == Role.student) {
        p.role = Role.student;
      } else {
        p.role = Role.tbd;
      }
    }
    r.status = RoomStatus.playing;
    return null;
  }
}

// ===== 進場頁：學生 / 鬼（用 SVG 顯示大圖示） =====

class MatchStudentPage extends StatelessWidget {
  const MatchStudentPage({super.key});
  @override
  Widget build(BuildContext context) => _matchScaffold(
    '你的身份是：學生（Match1）',
    SvgPicture.asset('assets/icons/student.svg', width: 72, height: 72),
    Colors.orange,
  );
}

class MatchHunterPage extends StatelessWidget {
  const MatchHunterPage({super.key});
  @override
  Widget build(BuildContext context) => _matchScaffold(
    '你的身份是：鬼（Match2）',
    SvgPicture.asset('assets/icons/ghost.svg', width: 72, height: 72),
    Colors.teal,
  );
}

Widget _matchScaffold(String title, Widget iconWidget, Color color) {
  return Scaffold(
    appBar: AppBar(title: const Text('角色分配完成')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 22, color: color)),
          const SizedBox(height: 24),
          const Text('（這裡接你的遊戲 HUD 與地圖）'),
        ],
      ),
    ),
  );
}
