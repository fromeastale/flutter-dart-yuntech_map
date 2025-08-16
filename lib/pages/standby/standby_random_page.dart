import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../demo/mock_match_demo.dart';

class StandbyRandomPage extends StatefulWidget {
  final String meId;
  final String meName;
  const StandbyRandomPage({super.key, required this.meId, required this.meName});

  @override
  State<StandbyRandomPage> createState() => _StandbyRandomPageState();
}

class _StandbyRandomPageState extends State<StandbyRandomPage> {
  @override
  Widget build(BuildContext context) {
    final room = MockServer.I.room!;
    final players = room.players;
    final total = players.length;
    final readyCount = players.where((p) => p.ready).length;
    final canStart = total >= 4 && readyCount == total && total > 0;

    return Scaffold(
      backgroundColor: const Color(0xFF80C8C7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showRules(context),
            tooltip: '玩法說明',
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                // 房型膠囊
                Container(
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/icons/room.svg', width: 30, height: 30),
                      const SizedBox(width: 12),
                      const Text('隨機', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      IconButton(
                        onPressed: () { setState(()=> MockServer.I.removeBot()); },
                        icon: const Icon(Icons.remove_circle_outline),
                        tooltip: '移除 Bot',
                      ),
                      IconButton(
                        onPressed: () { setState(()=> MockServer.I.addBot()); },
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: '加入 Bot',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 遊戲時間（可改）
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _pickDuration(context),
                  child: Container(
                    height: 59,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: [
                        const Text('遊戲時間', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Text('${room.durationSec ~/ 60} 分鐘',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 6),
                        const Icon(Icons.expand_more),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 玩家列表卡
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Icon(Icons.keyboard_arrow_up, color: Color(0xFF6E6E6E)),
                      const SizedBox(height: 8),
                      ...players.map(_playerTile),
                      const SizedBox(height: 8),
                      _waitingTile(),
                      const SizedBox(height: 8),
                      const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6E6E6E)),
                    ],
                  ),
                ),
              ],
            ),

            // 底部：PLAY
            Positioned(
              left: 0, right: 0, bottom: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 180, height: 56,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF00918E),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () {
                        final me = players.firstWhere((p) => p.id == widget.meId);
                        setState(()=> MockServer.I.toggleReady(widget.meId, !me.ready));
                        if (canStart) {
                          setState(()=> MockServer.I.startRandomAssign());
                          _goNext(context);
                        }
                      },
                      child: const Text(
                        'PLAY',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 32,
                          letterSpacing: -0.24,
                          color: Color(0xFFF6FFF3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 右下角固定：玩家總數（smile.svg + 數字）— 非互動
            Positioned(
              right: 16,
              bottom: 24,
              child: IgnorePointer(
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/smile.svg',
                      width: 24, height: 24,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        shadows: [Shadow(blurRadius: 6, color: Colors.black26)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 單筆玩家卡片
  Widget _playerTile(Player p) {
    final ready = p.ready;
    final dot = Container(
      width: 8, height: 8,
      decoration: BoxDecoration(
        color: ready ? const Color(0xFF4CAF50) : const Color(0xFFF5A625),
        shape: BoxShape.circle,
      ),
    );

    return Container(
      height: 71,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF80C8C7), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // avatar
          Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(color: Color(0xFF80C8C7), shape: BoxShape.circle),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/player.svg',
                width: 22, height: 22,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // name + ready
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  ready ? '已準備' : '未準備',
                  style: TextStyle(
                    fontSize: 12,
                    color: ready ? const Color(0xFF4CAF50) : const Color(0xFFF5A625),
                  ),
                ),
              ],
            ),
          ),
          dot,
        ],
      ),
    );
  }

  // 等待加入卡
  Widget _waitingTile() => Container(
    height: 71,
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F5F5),
      border: Border.all(color: const Color(0xFFE0E0E0)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      children: [
        CircleAvatar(radius: 22, backgroundColor: Color(0xFFE0E0E0), child: Text('？', style: TextStyle(color: Colors.black))),
        SizedBox(width: 12),
        Expanded(child: Text('等待加入...', style: TextStyle(color: Color(0xFF6E6E6E), fontSize: 15))),
      ],
    ),
  );

  // 規則彈窗
  void _showRules(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('鬼抓人（隨機房）規則'),
        content: const SingleChildScrollView(
          child: Text(
            '學生：完成任務點，前往逃離點；被鬼靠近（<5公尺）且長按3秒即被抓。\n'
                '鬼：靠近學生並長按「抓取」3秒，阻止學生在時限內逃離。\n'
                '\n待機階段：\n• 房間至少4人。\n• 每位玩家按 PLAY 代表「準備」。\n• 全員準備後自動開始，並依規則抽鬼：\n  3–6學⽣→1鬼、7–10→2鬼、11–14→3鬼…',
          ),
        ),
        actions: [TextButton(onPressed: ()=> Navigator.pop(ctx), child: const Text('了解'))],
      ),
    );
  }

  // 選時間：15 → 60，每 5 分鐘
  Future<void> _pickDuration(BuildContext ctx) async {
    final room = MockServer.I.room!;
    final mins = List<int>.generate(10, (i) => 15 + i * 5); // 15..60 step 5
    final current = room.durationSec ~/ 60;

    final picked = await showModalBottomSheet<int>(
      context: ctx,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ListView(
          children: [
            const ListTile(title: Text('選擇遊戲時間')),
            ...mins.map((m) => RadioListTile<int>(
              value: m,
              groupValue: current,
              onChanged: (v){ Navigator.pop(ctx, v); },
              title: Text('$m 分鐘'),
            )),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (picked != null) {
      setState(()=> room.durationSec = picked * 60);
    }
  }

  // 進下一頁
  void _goNext(BuildContext context) {
    final me = MockServer.I.room!.players.firstWhere((p) => p.id == 'me');
    if (MockServer.I.room!.status != RoomStatus.playing) return;
    if (me.role == Role.student) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MatchStudentPage()));
    } else if (me.role == Role.hunter) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MatchHunterPage()));
    }
  }
}

