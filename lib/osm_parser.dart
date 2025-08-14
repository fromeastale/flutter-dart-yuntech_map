import 'package:xml/xml.dart';
import 'package:latlong2/latlong.dart';
import 'models/building.dart';

class OsmParser {
  final String xmlContent;

  OsmParser(this.xmlContent);

  Future<List<LatLng>> parseBoundary(String wayId) async {
    final document = XmlDocument.parse(xmlContent);
    final nodes = <String, LatLng>{};

    for (final node in document.findAllElements('node')) {
      final id = node.getAttribute('id');
      final lat = double.tryParse(node.getAttribute('lat') ?? '');
      final lon = double.tryParse(node.getAttribute('lon') ?? '');
      if (id != null && lat != null && lon != null) {
        nodes[id] = LatLng(lat, lon);
      }
    }

    for (final way in document.findAllElements('way')) {
      if (way.getAttribute('id') == wayId) {
        final nds = way.findElements('nd')
            .map((nd) => nd.getAttribute('ref'))
            .whereType<String>()
            .toList();
        return nds.map((id) => nodes[id]).whereType<LatLng>().toList();
      }
    }

    return [];
  }

  Future<List<Building>> parseBuildings() async {
    final document = XmlDocument.parse(xmlContent);
    final buildings = <Building>[];

    for (final way in document.findAllElements('way')) {
      final tags = {
        for (final tag in way.findElements('tag'))
          if (tag.getAttribute('k') != null && tag.getAttribute('v') != null)
            tag.getAttribute('k')!: tag.getAttribute('v')!
      };

      if (tags.containsKey('building')) {
        final id = way.getAttribute('id') ?? '';
        final name = tags['name'] ?? 'Unnamed';
        final outline = await parseBoundary(id);
        final center = _calculateCentroid(outline);
        final type = _inferBuildingType(tags);

        buildings.add(Building(
          id: id,
          name: name,
          outline: outline,
          tags: tags,
          center: center,
          type: type,
        ));
      }
    }

    // TODO: 可擴充 relation 處理邏輯
    return buildings;
  }

  LatLng _calculateCentroid(List<LatLng> points) {
    double lat = 0;
    double lon = 0;
    for (var p in points) {
      lat += p.latitude;
      lon += p.longitude;
    }
    return LatLng(lat / points.length, lon / points.length);
  }

  BuildingType _inferBuildingType(Map<String, String> tags) {
    final typeTag = tags['building:use'] ?? tags['amenity'] ?? '';
    if (typeTag.contains('administration')) return BuildingType.administrative;
    if (typeTag.contains('education') || typeTag.contains('lecture')) return BuildingType.academic;
    if (typeTag.contains('theatre') || typeTag.contains('art')) return BuildingType.cultural;
    return BuildingType.unknown;
  }
}