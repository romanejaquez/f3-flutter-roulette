import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_roulette/models/roulette_device.dart';
import 'package:flutter_roulette/models/roulette_light_state.dart';
import 'package:flutter_roulette/models/roulette_spin.dart';
import 'package:flutter_roulette/services/roulette_http_service.dart';
import 'package:flutter_roulette/services/roulette_list_manager.dart';

final dbProvider = Provider((ref) {
  return FirebaseFirestore.instance;
});

final rouletteProvider = StreamProvider.family<RouletteSpin, Function>((ref, callback) async* {

  final rouletteEvents = ref.read(dbProvider).collection('roulette-events').doc('roulette-spins')
    .snapshots().map((event) => RouletteSpin.fromFirebase((event.data() as Map<String, dynamic>)));

  await for (var event in rouletteEvents) {
    callback(event);
  }
});

final rouletteHttpProvider = Provider.autoDispose((ref) {
  return RouletteHTTPService();
});

final lightTurnProvider = FutureProvider.autoDispose.family<bool, RouletteDevice>((ref, RouletteDevice device) {
  return ref.read(rouletteHttpProvider).turnDevice(device);
});

final rouletteDevicesProvider = FutureProvider<List<RouletteDevice>>((ref) async {

  final devicesDoc = await ref.read(dbProvider).collection('roulette-events').doc('roulette_devices').get();
  final rawDevicesList = (devicesDoc.data() as Map<String, dynamic>)['devices'] as List<dynamic>;
  return RouletteDevice.fromFirebaseList(rawDevicesList);
});

final rouletteListManagerProvider = Provider((ref) {
  return RouletteListManager();
});