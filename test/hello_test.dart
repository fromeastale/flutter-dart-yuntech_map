import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/main.dart'; // 確保路徑正確

void main() {
  testWidgets('HelloTestPage 顯示文字並能點擊按鈕', (WidgetTester tester) async {
    // 建立測試用 widget
    await tester.pumpWidget(const MyApp());

    // 驗證畫面是否顯示預期文字
    expect(find.text("👋 Hello, Flutter! 測試畫面"), findsOneWidget);

    // 驗證是否沒有其他文字
    expect(find.text("未定義文字"), findsNothing);
  });
}
