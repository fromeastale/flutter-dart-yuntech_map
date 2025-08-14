import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class Game6 extends StatefulWidget {
  const Game6({super.key});

  @override
  State<Game6> createState() => _Game6State();
}

class _Game6State extends State<Game6> {
  // ⏱️ 遊戲狀態變數
  int beatCount = 0;
  int failCount = 0;
  int totalFailCount = 0;
  int comboCount = 0;
  int countdown = 3;
  int gameDuration = 60;
  int elapsedTime = 0;
  int maxCombo = 0;
  int correctCount = 0;

  bool gameStarted = false;
  bool showOverlay = true;
  bool tappedThisBeat = false;

  DateTime lastBeatTime = DateTime.now();
  Timer? countdownTimer;
  Timer? heartbeatTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown(); // ⏳ 進入遊戲前倒數
  }

  // ⏳ 倒數計時：倒數 3 秒後開始遊戲
  void _startCountdown() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown == 0) {
        timer.cancel();
        setState(() {
          gameStarted = true;
          showOverlay = false;
          _startHeartbeat(); // ❤️ 啟動心跳節拍
        });
      } else {
        setState(() => countdown--);
      }
    });
  }

  // ❤️ 每秒節拍，用來判斷使用者點擊是否及時
  void _startHeartbeat() {
    heartbeatTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      lastBeatTime = DateTime.now();
      beatCount++;
      elapsedTime++;

      if (elapsedTime >= 7) {
        if (!tappedThisBeat) {
          failCount++;
          comboCount = 0;
        }

        if (failCount >= 5) {
          gameDuration += 30;
          failCount = 0;
          totalFailCount++;
        }

        if (elapsedTime - 5 > gameDuration) {
          timer.cancel();
          _showResultDialog(); // 顯示結束彈窗
          return;
        }
      }

      tappedThisBeat = false;
      setState(() {});
    });
  }

  // 👆 玩家點擊判斷：若拍點正確就算成功
  void _onClick() {
    if (elapsedTime <= 5 || tappedThisBeat) return;

    final now = DateTime.now();
    final diff = now.difference(lastBeatTime).inMilliseconds;

    if (diff.abs() <= 500) {
      tappedThisBeat = true;
      comboCount++;
      maxCombo = max(comboCount, maxCombo);
      correctCount++; // 成功計數
    } else {
      failCount++;
      comboCount = 0;

      if (failCount >= 5) {
        gameDuration += 30;
        failCount = 0;
      }
    }

    setState(() {});
  }

  // 🏁 顯示挑戰完成彈窗
  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('挑戰完成！'),
        content: Text(
          '完成節拍：$beatCount\n'
              '答對次數：$correctCount\n'
              '最高連擊：$maxCombo',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false); // 回主畫面
            },
            child: const Text('返回主畫面'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    heartbeatTimer?.cancel();
    countdownTimer?.cancel();
    super.dispose();
  }  // 顯示遊戲進行中的畫面內容
  Widget _buildGameContent() {
    final remainingTime = max(gameDuration - (elapsedTime - 5), 0); // 計算剩餘遊戲時間

    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HeartBeatWidget(beatCount: beatCount), // ❤️ 顯示心跳圖與拍數
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: (elapsedTime > 5) ? _onClick : null, // ⏳ 緩衝期後才能點擊
                child: Text(
                  (elapsedTime <= 5)
                      ? '請等待 ${5 - elapsedTime} 秒後開始點擊' // 提示倒數
                      : '點擊',
                ),
              ),
              Text('錯誤次數：$failCount'),
              Text('連擊次數：$comboCount'),
            ],
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Text(
            '剩餘時間：$remainingTime 秒',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // 構建整體 Scaffold 頁面：包含遊戲區塊與提示遮罩
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('心律穩定')),
      body: Stack(
        children: [
          if (gameStarted) _buildGameContent(), // 顯示遊戲內容
          if (showOverlay) // 初始倒數提示遮罩
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '提示：請依照心形的節奏點擊\n遊戲開始後有緩衝五秒的時間',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      '$countdown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 🫀 心跳 Widget：結合 CustomPaint 與文字資訊
class HeartBeatWidget extends StatelessWidget {
  final int beatCount;
  const HeartBeatWidget({super.key, required this.beatCount});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HeartPainter(),
      child: SizedBox(
        width: 150,
        height: 150,
        child: Center(
          child: Text(
            '60 BPM\n第 $beatCount 拍',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// 🖌️ 自訂心形圖案繪製器
class HeartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.pinkAccent
      ..style = PaintingStyle.fill;

    final path = Path();
    final width = size.width;
    final height = size.height;

    // 使用 cubic Bezier 畫出心形輪廓
    path.moveTo(width / 2, height * 0.8);
    path.cubicTo(width * 1.2, height * 0.4, width * 0.8, height * -0.1, width / 2, height * 0.3);
    path.cubicTo(width * 0.2, height * -0.1, -width * 0.2, height * 0.4, width / 2, height * 0.8);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}