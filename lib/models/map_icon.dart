import 'package:latlong2/latlong.dart';

class MapIcon {
  final String id;
  final LatLng position;
  final String assetPath;

  MapIcon({
    required this.id,
    required this.position,
    required this.assetPath,
  });
}