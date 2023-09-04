import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_roulette/enums.dart';
import 'package:flutter_roulette/providers.dart';
import 'package:rive/rive.dart';

class RouletteWheel extends ConsumerStatefulWidget {
  const RouletteWheel({super.key});

  @override
  ConsumerState<RouletteWheel> createState() => _RouletteWheelState();
}

class _RouletteWheelState extends ConsumerState<RouletteWheel> {

  late RiveAnimation anim;
  late StateMachineController smController;
  Map<RouletteOptions, SMITrigger> rouletteOptions = {};
  bool isRiveInitialized = false;

  @override
  void initState() {
    super.initState();

    anim = RiveAnimation.asset(
      'assets/anims/roulette.riv',
      artboard: 'roulette',
      onInit: onRiveInit,
    );
  }

  void onRiveInit(Artboard ab) {

    smController = StateMachineController.fromArtboard(
      ab, 'roulette')!;

    ab.addController(smController);

    for(var value in RouletteOptions.values) {
      rouletteOptions[value] = smController.findSMI(value.name) as SMITrigger;
    }

    setState(() {
      isRiveInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {

    final rouletteValue = ref.watch(rouletteProvider);

    return rouletteValue.when(
      data: (streamData) {

        if (isRiveInitialized) {
          rouletteOptions[streamData.spin]!.fire();
        }

        return SizedBox(
          key: ValueKey(streamData.timeStamp),
          width: 500,
          height: 500,
          child: anim,
        );
      }, 
      error:(error, stackTrace) => Text('error'), 
      loading:() => Text('loading'),
    );
  }
}