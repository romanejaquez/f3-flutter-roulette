import 'package:flutter_roulette/enums.dart';

class RouletteDevice {
  final RouletteOptions option;
  final String ipAddress;
  final String deviceChannel;
  bool isOn;

  RouletteDevice({
    required this.option,
    required this.ipAddress,
    required this.deviceChannel,
    this.isOn = false,
  });

  factory RouletteDevice.fromFirebase(Map<String, dynamic> json) {
    return RouletteDevice(
      option: RouletteOptions.values.firstWhere((e) => e.name == json['option']), 
      ipAddress: json['ipAddress'], 
      deviceChannel: json['deviceChannel'],
    );
  }

  static List<RouletteDevice> fromFirebaseList(List<dynamic> devices) {
    return devices.map((e) => RouletteDevice.fromFirebase(e as Map<String, dynamic>)).toList();
  }

  RouletteDevice copyWith({
    RouletteOptions? option,
    String? ipAddress,
    String? deviceChannel,
    bool? isOn,
  }) {
    return RouletteDevice(
      option: option ?? this.option, 
      ipAddress: ipAddress ?? this.ipAddress, 
      deviceChannel: deviceChannel ?? this.deviceChannel,
      isOn: isOn ?? this.isOn,  
    );
  }
}