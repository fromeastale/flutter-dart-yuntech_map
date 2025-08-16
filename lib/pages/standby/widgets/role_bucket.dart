import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RoleBucket extends StatelessWidget {
  final String label;
  final String iconPath; // 'assets/icons/ghost.svg' / 'assets/icons/student.svg'
  final int count;
  final int need;
  final bool selectedByMe;
  final VoidCallback onTap;

  const RoleBucket({
    super.key,
    required this.label,
    required this.iconPath,
    required this.count,
    required this.need,
    required this.selectedByMe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ok = count <= need;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: selectedByMe ? Colors.teal.withOpacity(.25) : Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ok ? Colors.white24 : Colors.redAccent),
        ),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SvgPicture.asset(iconPath, width: 28, height: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('已選：$count / 需要：$need'),
          ]),
        ),
      ),
    );
  }
}
