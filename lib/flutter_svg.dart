import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('SVG 圖片展示')),
        body: Center(
          child: SvgPicture.asset(
            'assets/images/sample.svg', // 確保這個路徑正確
            width: 150,
            height: 150,
            semanticsLabel: '範例 SVG',
          ),
        ),
      ),
    );
  }
}
