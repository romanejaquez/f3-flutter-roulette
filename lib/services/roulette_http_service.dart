import 'dart:async';

import 'package:flutter_roulette/models/roulette_device.dart';
import 'package:flutter_roulette/models/roulette_light_state.dart';
import 'package:http/http.dart' as http;

class RouletteHTTPService {


  Future<bool> turnDevice(RouletteDevice device) {
    final completer = Completer<bool>();
    
    final uri = Uri.parse('http://${device.ipAddress}/relay/${device.deviceChannel}?turn=${device.isOn ? 'on' : 'off'}');
    final lightState = http.get(uri).then((value) {
      completer.complete(true);
    }).catchError(() {
      completer.completeError(false);
    }).onError((error, stackTrace) {
      completer.completeError(error.toString());
    });

    return completer.future;
  }
}