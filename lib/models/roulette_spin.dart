import 'package:flutter_roulette/enums.dart';

class RouletteSpin {

  final RouletteOptions spin;
  final DateTime timeStamp;

  RouletteSpin({
    required this.spin,
    required this.timeStamp, 
  });

  factory RouletteSpin.fromFirebase(Map<String, dynamic> json) {
    return RouletteSpin(
      spin: RouletteOptions.values.firstWhere((element) => element.index == json['spin']),
      timeStamp: DateTime.parse(json['timestamp']),
    );
  }

  RouletteSpin copyWith({
    RouletteOptions? spin,
    DateTime? timeStamp,
  }) {
    return RouletteSpin(
      spin: spin ?? this.spin,
      timeStamp: timeStamp ?? this.timeStamp
    );
  }
}