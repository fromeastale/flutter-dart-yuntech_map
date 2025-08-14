import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Info Page')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(radius: 36, child: Icon(Icons.person, size: 36)),
          const SizedBox(height: 12),
          TextField(decoration: const InputDecoration(labelText: '暱稱', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: SwitchListTile(title: const Text('音效'), value: true, onChanged: (_){})),
            Expanded(child: SwitchListTile(title: const Text('震動'), value: true, onChanged: (_){})),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: FilledButton(onPressed: (){}, child: const Text('保存設定'))),
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton(onPressed: (){}, child: const Text('登出'))),
          ]),
        ],
      ),
    );
  }
}
