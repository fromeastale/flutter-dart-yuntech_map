import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../demo/mock_match_demo.dart';
import 'standby/standby_random_page.dart';
import 'standby/standby_private_page.dart';

// 小遊戲測試用，可刪 ↓↓↓
import '../games/qte_circular_game.dart' as mini1;       // QTECircularGame
import '../games/color_blind_test_game.dart' as mini2;   // ColorBlindTestGame
// 小遊戲測試用，可刪 ↑↑↑

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6F3),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            _profileHeader(context), // 成就1/2 連到小遊戲（測試用）

            const SizedBox(height: 16),

            _sectionCard(
              title: '散 步',
              children: [
                _menuTile(
                  leading: const Icon(Icons.directions_walk_outlined),
                  title: '單純散步（計算里程）',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('之後接：散步（計步/里程）')),
                  ),
                ),
                _menuTile(
                  leading: const Icon(Icons.route_outlined),
                  title: '沿附近路線散步',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('之後接：路線散步')),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _sectionCard(
              title: '鬼 抓 人',
              children: [
                _menuTile(
                  leading: SvgPicture.asset(
                    'assets/icons/random.svg',
                    width: 24, height: 24,
                    colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
                  ),
                  title: '隨機房',
                  onTap: () {
                    MockServer.I.createRandomRoom('me', '我');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StandbyRandomPage(meId: 'me', meName: '我'),
                      ),
                    );
                  },
                ),
                _menuTile(
                  leading: SvgPicture.asset(
                    'assets/icons/room.svg',
                    width: 24, height: 24,
                    colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
                  ),
                  title: '私人房',
                  onTap: () async {
                    final code = await _askPrivateCode(context);
                    if (code == null) return;
                    MockServer.I.createPrivateRoom('me', '我', code);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StandbyPrivatePage(meId: 'me', meName: '我', code: code),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 若也想在頁面底部放兩顆測試按鈕，可取消下一行註解
            // _miniGameTestPanel(context), // 小遊戲測試用，可刪
          ],
        ),
      ),
    );
  }

  /// 頭像＋名稱＋成就列（成就1：QTE、成就2：色盲） —— 小遊戲測試用，可刪
  Widget _profileHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28, backgroundColor: Color(0xFF80C8C7),
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('玩家名稱', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    SizedBox(height: 2),
                    Text('簡介', style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // 成就1 → QTE 圓環 —— 小遊戲測試用，可刪
              _chipButton(
                label: '成就1',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => mini1.QTECircularGame( // 類名要全大寫 QTE
                        onGameEnd: (bool _) => Navigator.pop(context),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              // 成就2 → 色盲測試 —— 小遊戲測試用，可刪
              _chipButton(
                label: '成就2',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => mini2.ColorBlindTestGame(
                        onGameEnd: (bool _) => Navigator.pop(context), // 需要 bool 參數
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              _chipButton(label: '成就3', onTap: () {}),
            ],
          ),
        ],
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

  Widget _menuTile({
    required Widget leading,
    required String title,
    required VoidCallback onTap,
  }) {
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

  // 小遊戲測試用，可刪（若想在頁面底部再放兩顆測試按鈕，解註這個方法的呼叫）
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
                    builder: (_) => mini1.QTECircularGame(
                      onGameEnd: (bool _) => Navigator.pop(context),
                    ),
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
                    builder: (_) => mini2.ColorBlindTestGame(
                      onGameEnd: (bool _) => Navigator.pop(context),
                    ),
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
}
