import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../screens/map_screen.dart';
import '../models/building.dart';

class HomePage extends StatelessWidget {
  final List<LatLng> boundary;
  final List<Building> buildings;

  const HomePage({
    required this.boundary,
    required this.buildings,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapScreen(
        boundary: boundary,
        buildings: [],
      ),
    );
  }
}