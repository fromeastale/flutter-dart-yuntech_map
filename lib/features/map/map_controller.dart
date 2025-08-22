import 'package:flutter/foundation.dart';

class MapController extends ChangeNotifier {
  final Map<String, bool> visibility = {
    'toilet': true,
    'elevator': false,
    'atm': true,
  };

  void toggleVisibility(String id) {
    visibility[id] = !(visibility[id] ?? false);
    notifyListeners();
  }
}