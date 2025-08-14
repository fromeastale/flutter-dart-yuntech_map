// lib/utils/osm_loader.dart
import 'package:flutter/services.dart' show rootBundle;

Future<String> loadOsmFile() async {
  return await rootBundle.loadString('assets/maps/images/map.osm');
}