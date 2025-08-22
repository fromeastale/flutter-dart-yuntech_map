import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../logic/mock_match_demo.dart';

class StandbyPrivatePage extends StatefulWidget {
  final String meId; final String meName; final String code;
  const StandbyPrivatePage({super.key, required this.meId, required this.meName, required this.code});

  @override
  State<StandbyPrivatePage> createState() => _StandbyPrivatePageState();
}

class _StandbyPrivatePageState extends State<StandbyPrivatePage> {
  @override
  Widget build(BuildContext context) {
    final room = MockServer.I.room!;
    final players = room.players;
    final total = players.length;

    final needHunters = calcHuntersForTotalPlayers(total);
    final pickedHunters = players.where((p)=>p.pickedRole==Role.hunter).length;
    final pickedStudents = players.where((p)=>p.pickedRole==Role.student).length;
    final isHost = room.hostId == widget.meId;

    final picked = players.where((p)=>p.pickedRole!=Role.tbd).toList();
    final allPickedReady = picked.isNotEmpty && picked.every((p)=>p.ready);
    final canHostStart = isHost && pickedHunters==needHunters && allPickedReady;

    return Scaffold(
      backgroundColor: const Color(0xFF80C8C7),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
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
                // 房號膠囊
                Container(
                  height: 58,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/icons/room.svg', width: 30, height: 30),
                      const SizedBox(width: 12),
                      Text(widget.code, style: const TextStyle(fontSize: 28, letterSpacing: 6, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      // 加/減 Bot（測試用）
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

                // 隨機分配 + 遊戲時間
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 59,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: isHost ? () {
                            setState(()=> MockServer.I.randomizePrivatePicks());
                          } : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset('assets/icons/btnRandom.svg', width: 24, height: 24,
                                  colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
                              const SizedBox(width: 8),
                              const Text('隨機分配'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _pickDuration(context),
                        child: Container(
                          height: 59,
                          decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Row(
                            children: [
                              const Text('時間', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              const Spacer(),
                              Text('${room.durationSec ~/ 60} 分鐘',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              const SizedBox(width: 6),
                              const Icon(Icons.expand_more),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 左右兩個角色桶
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _roleBucket(
                      label: '加入鬼',
                      iconPath: 'assets/icons/ghost.svg',
                      count: pickedHunters,
                      need: needHunters,
                      selected: _mePicked(Role.hunter),
                      onTap: () { setState(()=> MockServer.I.pickRole(widget.meId, Role.hunter)); },
                      players: players.where((p)=>p.pickedRole==Role.hunter).toList(),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _roleBucket(
                      label: '加入學生',
                      iconPath: 'assets/icons/student.svg',
                      count: pickedStudents,
                      need: total - needHunters,
                      selected: _mePicked(Role.student),
                      onTap: () { setState(()=> MockServer.I.pickRole(widget.meId, Role.student)); },
                      players: players.where((p)=>p.pickedRole==Role.student).toList(),
                    )),
                  ],
                ),
              ],
            ),

            // 底部：PLAY（房主/玩家邏輯不同）
            Positioned(
              left: 0, right: 0, bottom: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 180, height: 56,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF00918E), shape: const StadiumBorder()),
                      onPressed: () {
                        final me = players.firstWhere((p)=>p.id==widget.meId);
                        if (!isHost) {
                          setState(()=> MockServer.I.toggleReady(widget.meId, !me.ready)); // 玩家：切換準備
                        } else {
                          if (canHostStart) {
                            final err = MockServer.I.startPrivateByHost(widget.meId);
                            if (err != null) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                            } else {
                              _goNext(context);
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('需：鬼數量正確，且所有已選角色的玩家都按準備')),
                            );
                          }
                        }
                      },
                      child: const Text('PLAY',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -0.24, color: Color(0xFFF6FFF3))),
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
                    SvgPicture.asset('assets/icons/smile.svg', width: 24, height: 24,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                    const SizedBox(width: 6),
                    Text('$total',
                      style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18,
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

  // ===== UI 子區塊 =====

  Widget _roleBucket({
    required String label,
    required String iconPath,
    required int count,
    required int need,
    required bool selected,
    required VoidCallback onTap,
    required List<Player> players,
  }) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(.9), borderRadius: BorderRadius.circular(22)),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        children: [
          Row(children: [
            SvgPicture.asset(iconPath, width: 22, height: 22),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('$count / $need'),
          ]),
          const SizedBox(height: 8),
          ...players.map(_miniPlayerCard),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(selected ? '已選擇' : '加入'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniPlayerCard(Player p) {
    final ready = p.ready;
    final dot = Container(
      width: 8, height: 8,
      decoration: BoxDecoration(
        color: ready ? const Color(0xFF4CAF50) : const Color(0xFFF5A625),
        shape: BoxShape.circle,
      ),
    );
    return Container(
      height: 64,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF80C8C7)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(color: Color(0xFF80C8C7), shape: BoxShape.circle),
            child: Center(
              child: SvgPicture.asset('assets/icons/player.svg',
                  width: 20, height: 20, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: const TextStyle(fontSize: 14)),
                Text(ready ? '已準備' : '未準備',
                    style: TextStyle(fontSize: 12, color: ready ? const Color(0xFF4CAF50) : const Color(0xFFF5A625))),
              ],
            ),
          ),
          dot,
        ],
      ),
    );
  }

  // ===== 輔助動作 =====

  bool _mePicked(Role r) {
    final me = MockServer.I.room!.players.firstWhere((p)=>p.id=='me');
    return me.pickedRole == r;
  }

  void _showRules(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('鬼抓人（私人房）規則'),
        content: const SingleChildScrollView(
          child: Text(
            '1) 房主可按「隨機分配」快速分配角色（之後玩家仍可手動改桶）。\n'
                '2) 玩家按 PLAY → 切換為「準備」。\n'
                '3) 房主按 PLAY：\n'
                '   • 鬼數量符合規則（3–6學⽣→1鬼、7–10→2鬼、11–14→3鬼…）\n'
                '   • 且所有已選角色的玩家都已準備\n'
                '   → 即可開始；未選角色者會離開並回到遊戲頁。',
          ),
        ),
        actions: [TextButton(onPressed: ()=> Navigator.pop(ctx), child: const Text('了解'))],
      ),
    );
  }

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

  void _goNext(BuildContext context) {
    final r = MockServer.I.room!;
    final me = r.players.firstWhere((p) => p.id == 'me');

    // 已開始
    if (r.status != RoomStatus.playing) return;

    // 角色未分配（tbd）者退回 Game Page
    if (me.role == Role.tbd) {
      Navigator.pop(context);
      return;
    }

    if (me.role == Role.student) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const MatchStudentPage()));
    } else if (me.role == Role.hunter) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const MatchHunterPage()));
    }
  }
}
