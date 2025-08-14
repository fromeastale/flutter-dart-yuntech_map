import 'package:flutter/material.dart';

class GameEntryButton extends StatelessWidget {
  final String title;
  final String? routeName;
  final Widget? screen;

  const GameEntryButton({
    required this.title,
    this.routeName,
    this.screen,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    print("🕹️ GameEntryButton for $title rendered");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        child: Text(title),
        onPressed: () {
          if (screen != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen!),
            );
          } else if (routeName != null) {
            Navigator.pushNamed(context, routeName!);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("❌ 沒有指定 routeName 或 screen")),
            );
          }
        },
      ),
    );
  }
}