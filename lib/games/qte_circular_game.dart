import 'dart:math';
import 'package:flutter/material.dart';

class QTECircularGame extends StatefulWidget {
  final void Function(bool success) onGameEnd;
  const QTECircularGame({super.key, required this.onGameEnd});

  @override
  State<QTECircularGame> createState() => _QTECircularGameState();
}

class _QTECircularGameState extends State<QTECircularGame> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const int baseRequired = 6;
  int currentSolved = 0;
  int mistakeCount = 0;

  late double hitStartAngle;
  late double hitSweepAngle;
  late double perfectSpot;
  bool acceptingInput = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && acceptingInput) {
          _fail(); // 超時未點視為失誤
        }
      });
    _startRound();
  }

  void _startRound() {
    setState(() {
      acceptingInput = true;
      final rand = Random();
      hitStartAngle = rand.nextDouble() * 2 * pi;
      hitSweepAngle = pi / 6; // 30°
      perfectSpot = hitStartAngle + hitSweepAngle / 2;
    });
    _controller.forward(from: 0);
  }

  void _onTap() {
    if (!acceptingInput) return;
    setState(() => acceptingInput = false);

    final pointerAngle = _controller.value * 2 * pi;
    final inHit = _angleInRange(pointerAngle, hitStartAngle, hitStartAngle + hitSweepAngle);
    if (inHit) {
      currentSolved++;
      final required = baseRequired + mistakeCount; // 錯一次加一題
      if (currentSolved >= required) {
        _controller.stop(); // 可選：避免動畫還在跑
        widget.onGameEnd(true);
        return;
      }
    } else {
      _registerMistake();
    }
    Future.delayed(const Duration(milliseconds: 350), _startRound);
  }

  void _fail() {
    if (!acceptingInput) return;
    setState(() => acceptingInput = false);
    _registerMistake();
    Future.delayed(const Duration(milliseconds: 350), _startRound);
  }

  void _registerMistake() {
    setState(() {
      mistakeCount++;
      // 規則：錯一次加一題 → 只增加總需求，不增加已解
      // 顯示總需求時用 baseRequired + mistakeCount
    });
  }

  bool _angleInRange(double angle, double start, double end) {
    angle %= 2 * pi; start %= 2 * pi; end %= 2 * pi;
    if (start < end) return angle >= start && angle <= end;
    return angle >= start || angle <= end;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pointerAngle = _controller.value * 2 * pi;
    final totalRequired = baseRequired + mistakeCount;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('QTE 精準點擊  ($currentSolved/$totalRequired)',
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 18),
              CustomPaint(
                size: const Size(220, 220),
                painter: _CircleQTEPainter(
                  pointerAngle: pointerAngle,
                  hitStartAngle: hitStartAngle,
                  hitSweepAngle: hitSweepAngle,
                  perfectAngle: perfectSpot,
                ),
              ),
              const SizedBox(height: 16),
              const Text('任意點擊畫面以判定', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              Text('錯誤：$mistakeCount', style: const TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleQTEPainter extends CustomPainter {
  final double pointerAngle;
  final double hitStartAngle;
  final double hitSweepAngle;
  final double perfectAngle;
  const _CircleQTEPainter({
    required this.pointerAngle,
    required this.hitStartAngle,
    required this.hitSweepAngle,
    required this.perfectAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 10;

    final ring = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final hit = Paint()
      ..color = Colors.white.withOpacity(0.33)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    final perfect = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    final pointer = Paint()
      ..color = Colors.red
      ..strokeWidth = 3;

    // base ring
    canvas.drawCircle(center, radius, ring);

    // hit zone arc
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        hitStartAngle, hitSweepAngle, false, hit);

    // perfect tiny arc at center of hit zone
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        perfectAngle - 0.02, 0.04, false, perfect);

    // pointer (red line)
    final p = Offset(center.dx + radius * cos(pointerAngle),
        center.dy + radius * sin(pointerAngle));
    canvas.drawLine(center, p, pointer);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
