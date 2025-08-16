import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../demo/mock_match_demo.dart';

class PlayerList extends StatelessWidget {
  final List<Player> players;
  final String? meId;
  final bool showPickedRole; // 私人房：顯示玩家「選擇」狀態
  const PlayerList({
    super.key,
    required this.players,
    this.meId,
    this.showPickedRole = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (_, i) {
        final p = players[i];

        Widget leading;
        if (showPickedRole) {
          leading = p.pickedRole == Role.hunter
              ? SvgPicture.asset('assets/icons/ghost.svg', width: 24, height: 24)
              : p.pickedRole == Role.student
              ? SvgPicture.asset('assets/icons/student.svg', width: 24, height: 24)
              : const Icon(Icons.help_outline);
        } else {
          leading = p.role == Role.hunter
              ? SvgPicture.asset('assets/icons/ghost.svg', width: 24, height: 24)
              : p.role == Role.student
              ? SvgPicture.asset('assets/icons/student.svg', width: 24, height: 24)
              : Icon(p.ready ? Icons.check_circle : Icons.hourglass_empty);
        }

        return ListTile(
          leading: leading,
          title: Text(p.name + (p.id == meId ? '（你）' : '')),
          subtitle: showPickedRole
              ? Text('選擇：${p.pickedRole.name}')
              : Text(p.ready ? '已準備' : '未準備'),
        );
      },
    );
  }
}
