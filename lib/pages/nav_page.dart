import 'package:flutter/material.dart';

class NavPage extends StatelessWidget {
  const NavPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Page')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(
                hintText: '輸入關鍵字地點、樓層或教室',
                prefixIcon: Icon(Icons.search), border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: [
              FilledButton.tonal(onPressed: (){}, child: const Text('手動定位')),
              FilledButton.tonal(onPressed: (){}, child: const Text('常用地點')),
              FilledButton.tonalIcon(onPressed: (){}, icon: const Icon(Icons.view_in_ar), label: const Text('3D')),
            ]),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.black12, borderRadius: BorderRadius.circular(12)),
                child: const Text('（之後放 3D/平面導航預覽）'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
