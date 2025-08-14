import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showToilet = true, showParking = false, showAtm = false, showWater = false, showElev = false, showAccessible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Stack(
        children: [
          // TODO: 之後換成 flutter_map 實際地圖
          Positioned.fill(child: Container(color: const Color(0xFF0F1317))),
          Positioned(
            top: 16, right: 16,
            child: FloatingActionButton.small(
              child: const Icon(Icons.near_me),
              onPressed: () => _openLayerPanel(context),
            ),
          ),
        ],
      ),
    );
  }

  void _openLayerPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const ListTile(leading: Icon(Icons.map), title: Text('地圖資訊')),
          SwitchListTile(value: showToilet,     onChanged: (v)=> setState(()=> showToilet=v),     title: const Text('廁所')),
          SwitchListTile(value: showParking,    onChanged: (v)=> setState(()=> showParking=v),    title: const Text('停車場')),
          SwitchListTile(value: showAtm,        onChanged: (v)=> setState(()=> showAtm=v),        title: const Text('ATM')),
          SwitchListTile(value: showWater,      onChanged: (v)=> setState(()=> showWater=v),      title: const Text('飲水機')),
          SwitchListTile(value: showElev,       onChanged: (v)=> setState(()=> showElev=v),       title: const Text('電梯')),
          SwitchListTile(value: showAccessible, onChanged: (v)=> setState(()=> showAccessible=v), title: const Text('無障礙空間')),
        ]),
      ),
    );
  }
}
