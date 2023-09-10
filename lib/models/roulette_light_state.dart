class RouletteLightState {

  final bool ison;

  RouletteLightState({
    required this.ison,
  });

  factory RouletteLightState.fromJSON(Map<String, dynamic> json) {
    return RouletteLightState(ison: json['ison']);
  }
}