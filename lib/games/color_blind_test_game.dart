import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ColorBlindTestGame extends StatefulWidget {
  final void Function(bool success) onGameEnd;
  const ColorBlindTestGame({super.key, required this.onGameEnd});

  @override
  State<ColorBlindTestGame> createState() => _ColorBlindTestGameState();
}

class _ColorBlindTestGameState extends State<ColorBlindTestGame> {
  static const int totalQuestions = 8;

  static const int distractorCount = 400;     // 雜訊數量
  static const double targetFontSize = 64;    // 目標大小
  static const double contrast = 0.14;        // 色差

  int current = 0;
  bool canTap = false;
  bool showInstruction = true;
  int waitSec = 5;
  final _rand = Random();

  Offset targetCenter = const Offset(160, 220);
  Rect _targetRect = Rect.zero;

  @override
  void initState() {
    super.initState();
    _nextQuestion();
  }

  void _nextQuestion() {
    setState(() {
      canTap = false;
      showInstruction = true;
      waitSec = 3;
      targetCenter = Offset(
        80 + _rand.nextDouble() * 200,
        140 + _rand.nextDouble() * 280,
      );
      _targetRect = _measureDigitRect('6', targetCenter, targetFontSize);
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() => showInstruction = false);
    });

    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (waitSec == 1) {
        t.cancel();
        setState(() => canTap = true);
      } else {
        setState(() => waitSec--);
      }
    });
  }

  Rect _measureDigitRect(String digit, Offset center, double fontSize) {
    final tp = TextPainter(
      text: TextSpan(
        text: digit,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return Rect.fromCenter(center: center, width: tp.size.width, height: tp.size.height);
  }

  void _onTap(TapUpDetails d) {
    if (!canTap) return;
    final hit = _targetRect.inflate(6).contains(d.localPosition);

    if (hit) {
      setState(() => current++);
      if (current >= totalQuestions) {
        widget.onGameEnd(true);
        return;
      }
      _nextQuestion();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('錯誤！再試一次'),
        duration: Duration(milliseconds: 520),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: _onTap,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _DigitNoisePainter(
                  targetCenter: targetCenter,
                  targetRect: _targetRect,
                  targetFontSize: targetFontSize,
                  distractorCount: distractorCount,
                  contrast: contrast,
                  rand: _rand,
                ),
              ),
            ),
            if (showInstruction)
              const Positioned(
                top: 56, left: 0, right: 0,
                child: Center(child: Text('找出數字：6', style: TextStyle(fontSize: 50, color: Colors.white))),
              ),
            if (!showInstruction && !canTap)
              Positioned(
                top: 56, left: 0, right: 0,
                child: Center(child: Text('等待：$waitSec 秒', style: TextStyle(fontSize: 35, color: Colors.white70))),
              ),
            Positioned(
              bottom: 36, left: 0, right: 0,
              child: Center(child: Text('進度：$current / $totalQuestions', style: const TextStyle(color: Colors.white))),
            ),
          ],
        ),
      ),
    );
  }
}

class _DigitNoisePainter extends CustomPainter {
  final Offset targetCenter;
  final Rect targetRect;
  final double targetFontSize;
  final int distractorCount;
  final double contrast;
  final Random rand;

  _DigitNoisePainter({
    required this.targetCenter,
    required this.targetRect,
    required this.targetFontSize,
    required this.distractorCount,
    required this.contrast,
    required this.rand,
  });

  Color _bgTone() {
    final r = 90 + rand.nextInt(130);
    final g = 100 + rand.nextInt(120);
    final b = 80 + rand.nextInt(90);
    return Color.fromARGB(255, r, g, b);
  }

  Color _targetTone(Color base) {
    int adj(int v, int delta) => (v + delta).clamp(0, 255).toInt();
    final d = (contrast * 60).round();
    return Color.fromARGB(255, adj(base.red, d), adj(base.green, -d), adj(base.blue, d ~/ 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF101010));

    // 干擾數字
    for (int i = 0; i < distractorCount; i++) {
      String digit;
      do {
        digit = rand.nextInt(10).toString();
      } while (digit == '6'); // 排除數字6

      // 干擾大小與目標接近（±10%）
      final fontSize = targetFontSize * (0.9 + rand.nextDouble() * 0.2);

      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      if (targetRect.inflate(8).contains(Offset(x, y))) continue;

      final color = _bgTone().withOpacity(0.6);

      final tp = TextPainter(
        text: TextSpan(text: digit, style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: color,
        )),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((rand.nextDouble() - 0.5) * 0.4);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
    }

    // 目標「6」
    final base = _bgTone();
    final targetColor = _targetTone(base);
    final tp = TextPainter(
      text: TextSpan(text: '6', style: TextStyle(
        fontSize: targetFontSize,
        fontWeight: FontWeight.w800,
        color: targetColor.withOpacity(0.88),
      )),
      textDirection: TextDirection.ltr,
    )..layout();
    final topLeft = Offset(targetCenter.dx - tp.size.width / 2, targetCenter.dy - tp.size.height / 2);
    canvas.save();
    canvas.translate(topLeft.dx + tp.size.width / 2, topLeft.dy + tp.size.height / 2);
    canvas.rotate(0.02);
    tp.paint(canvas, -tp.size.center(Offset.zero));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DigitNoisePainter old) => true;
}
