import 'package:flutter_roulette/enums.dart';
import 'package:flutter_roulette/models/roulette_device.dart';

class RouletteListManager {

  List<RouletteDevice> devicesList = [];

  void initializeList(List<RouletteDevice> list) {
    devicesList = list;
  }

  RouletteDevice getDeviceFromOption(RouletteOptions option) {
    return devicesList.where((e) => e.option == option).first;
  }
}