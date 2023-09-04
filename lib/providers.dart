import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_roulette/models/roulette_spin.dart';

final dbProvider = Provider((ref) {
  return FirebaseFirestore.instance;
});

final rouletteProvider = StreamProvider.autoDispose<RouletteSpin>((ref) async* {

  final rouletteEvents = ref.read(dbProvider).collection('roulette-events').doc('roulette-spins')
    .snapshots().map((event) => RouletteSpin.fromFirebase((event.data() as Map<String, dynamic>)));

  await for (var event in rouletteEvents) {
    yield event;
  }
});