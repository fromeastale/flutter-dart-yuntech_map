import 'package:flutter/material.dart';
import '../games/qte_circular_game.dart' as mini1;
import '../games/color_blind_test_game.dart' as mini2;
import '../games/game5.dart' as mini3;
import '../games/game6.dart' as mini4;
import '../games/game9.dart' as mini5;

class GameDevPage extends StatelessWidget {
  const GameDevPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('遊戲測試')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('請選擇要測試的遊戲：', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12, runSpacing: 12,
              children: [
                _testButton(context, 'QTE 圓環', () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => mini1.QTECircularGame(onGameEnd: (_) => Navigator.pop(context))),
                )),
                _testButton(context, '色盲測試', () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => mini2.ColorBlindTestGame(onGameEnd: (_) => Navigator.pop(context))),
                )),
                _testButton(context, 'Game5', () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => mini3.Game5()),
                )),
                _testButton(context, 'Game6', () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => mini4.Game6()),
                )),
                _testButton(context, 'Game9', () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => mini5.Game9()),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _testButton(BuildContext context, String label, VoidCallback onTap) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.play_arrow),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF00918E),
        shape: const StadiumBorder(),
      ),
    );
  }
}