import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/map_icon.dart';

class MapIconLayer extends StatelessWidget {
  final List<MapIcon> icons;

  const MapIconLayer({super.key, required this.icons});

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: icons.map((icon) {
        return Marker(
          point: icon.position,
          width: 32,
          height: 32,
          child: SvgPicture.asset(icon.assetPath),
        );
      }).toList(),
    );
  }
}