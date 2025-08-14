import 'dart:async'; // 用於倒數計時
import 'dart:math'; // 用於隨機產生驗證碼
import 'package:flutter/material.dart'; // Flutter UI 套件

// 遊戲頁面主入口
class Game5 extends StatefulWidget {
  const Game5({super.key});

  @override
  State<Game5> createState() => _Game5State();
}

// 遊戲主邏輯 State
class _Game5State extends State<Game5> {
  late String generatedCode; // 儲存產生的驗證碼
  late Timer timer; // 倒數計時器
  final inputController = TextEditingController(); // 使用者輸入控制器

  int currentRound = 1; // 當前題號
  int correctCount = 0; // 答對次數
  int remainingSeconds = 5; // 倒數時間（秒）
  String message = ''; // 回饋訊息（正確/錯誤）

  @override
  void initState() {
    super.initState();
    _startGame(); // 初始化時啟動遊戲
  }

  // 開始整個遊戲流程
  void _startGame() {
    currentRound = 1;
    correctCount = 0;
    _startRound(); // 啟動第一回合
  }

  // 開始單一題目（共 6 題）
  void _startRound() {
    if (currentRound > 6) {
      _showResultDialog(); // 若已超過 6 題，顯示結果
      return;
    }

    generatedCode = _generateCode(); // 產生新的驗證碼
    remainingSeconds = 5; // 重設倒數時間
    inputController.clear(); // 清空輸入欄位
    message = ''; // 清空回饋訊息

    // 啟動 1 秒一次的倒數計時器
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        remainingSeconds--;
        if (remainingSeconds <= 0) {
          t.cancel(); // 停止計時
          _handleAnswer(); // 自動送出答案
        }
      });
    });

    setState(() {}); // 更新 UI
  }

  // 隨機產生 4 位數驗證碼
  String _generateCode() {
    final rand = Random();
    return List.generate(4, (_) => rand.nextInt(10)).join(); // 例如 "8352"
  }

  // 判斷使用者答案正確與否
  void _handleAnswer() {
    final userInput = inputController.text;

    if (userInput == generatedCode) {
      correctCount++; // 答對則累加
      message = '✅ 正確！';
      currentRound++; // 進入下一題
    } else {
      message = '❌ 錯誤或超時';
      // 答錯不增加題號 → 留在同一題重答
    }

    setState(() {}); // 顯示答題結果

    // 1 秒後進入下一題（或重試）
    Future.delayed(const Duration(seconds: 1), () {
      _startRound();
    });
  }

  // 顯示挑戰結束的結果彈窗
  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('挑戰完成！'),
        content: Text('你總共答對了 $correctCount / 6 題'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 關閉彈窗
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
    timer.cancel(); // 清除 timer
    inputController.dispose(); // 釋放輸入欄位記憶體
    super.dispose();
  }

  // 遊戲 UI 建構
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('驗證碼挑戰')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 題號顯示
            Text('題目 $currentRound / 6', style: const TextStyle(fontSize: 18)),
            // 剩餘秒數顯示
            Text('剩餘時間：$remainingSeconds 秒', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            // 顯示驗證碼
            Text(
              '🔒 驗證碼： $generatedCode',
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
            ),
            const SizedBox(height: 24),
            // 輸入欄位
            TextField(
              controller: inputController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '輸入驗證碼',
              ),
            ),
            // 送出答案按鈕
            ElevatedButton(
              onPressed: () {
                timer.cancel(); // 中止倒數
                _handleAnswer(); // 手動送出答案
              },
              child: const Text('送出'),
            ),
            const SizedBox(height: 16),
            // 顯示回饋訊息
            Text(message, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}