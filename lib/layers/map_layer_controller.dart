class MapLayerController {
  bool showToilet = true;
  bool showParking = false;
  bool showAtm = false;
  bool showWater = false;
  bool showElevator = false;
  bool showAccessible = true;

  bool shouldShow(String type) {
    switch (type) {
      case 'toilet':
        return showToilet;
      case 'parking':
        return showParking;
      case 'atm':
        return showAtm;
      case 'water':
        return showWater;
      case 'elevator':
        return showElevator;
      case 'accessible':
        return showAccessible;
      default:
        return false;
    }
  }

  void toggle(String type, bool value) {
    switch (type) {
      case 'toilet':
        showToilet = value;
        break;
      case 'parking':
        showParking = value;
        break;
      case 'atm':
        showAtm = value;
        break;
      case 'water':
        showWater = value;
        break;
      case 'elevator':
        showElevator = value;
        break;
      case 'accessible':
        showAccessible = value;
        break;
    }
  }
}