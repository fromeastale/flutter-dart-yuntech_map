import 'package:flutter/material.dart';
import 'map_layer_controller.dart';

class MapInfoPanel extends StatelessWidget {
  final MapLayerController controller;
  final VoidCallback onChanged;

  const MapInfoPanel({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const ListTile(leading: Icon(Icons.map), title: Text('地圖資訊')),
        _buildSwitch('廁所', 'toilet'),
        _buildSwitch('停車場', 'parking'),
        _buildSwitch('ATM', 'atm'),
        _buildSwitch('飲水機', 'water'),
        _buildSwitch('電梯', 'elevator'),
        _buildSwitch('無障礙空間', 'accessible'),
      ]),
    );
  }

  Widget _buildSwitch(String label, String type) {
    return SwitchListTile(
      title: Text(label),
      value: controller.shouldShow(type),
      onChanged: (val) {
        controller.toggle(type, val);
        onChanged();
      },
    );
  }
}