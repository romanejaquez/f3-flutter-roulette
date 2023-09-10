import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_roulette/enums.dart';
import 'package:flutter_roulette/models/roulette_spin.dart';
import 'package:flutter_roulette/providers.dart';
import 'package:rive/rive.dart';

class RouletteWheel extends ConsumerStatefulWidget {
  const RouletteWheel({super.key});

  @override
  ConsumerState<RouletteWheel> createState() => _RouletteWheelState();
}

class _RouletteWheelState extends ConsumerState<RouletteWheel> {

  late RiveAnimation anim;
  late RiveAnimation resultAnim;
  late RiveAnimation introAnim;


  late StateMachineController smController;
  late StateMachineController resultSMController;
  late StateMachineController introSMController;


  Map<RouletteOptions, SMITrigger> rouletteOptions = {};
  Map<RouletteOptions, SMITrigger> resultOptions = {};
  Map<RouletteOptions, SMITrigger> resultBackOptions = {};
  Map<IntroOptions, SMITrigger> introOptions = {};

  bool isRiveInitialized = false;
  bool isResultRiveInitialized = false;
  RouletteSpin spinTurn = RouletteSpin(spin: RouletteOptions.flutter1, timeStamp: DateTime.now());
  bool isAnimationPlaying = false;
  

  @override
  void initState() {
    super.initState();

    anim = RiveAnimation.asset(
      'assets/anims/roulette.riv',
      artboard: 'roulette',
      onInit: onRiveInit,
      fit: BoxFit.contain,
    );

    resultAnim = RiveAnimation.asset(
      'assets/anims/roulette.riv',
      artboard: 'resultscreen',
      onInit: onRiveResultInit,
      fit: BoxFit.contain,
    );

    introAnim = RiveAnimation.asset(
      'assets/anims/roulette.riv',
      artboard: 'mainintro',
      onInit: onRiveIntroInit,
      fit: BoxFit.contain,
    );

    ref.read(rouletteProvider((RouletteSpin streamData) {

          //if (!isAnimationPlaying) {

            setState(() {
              spinTurn = streamData;
            });

            introOptions[IntroOptions.outro]!.fire();
            rouletteOptions[spinTurn.spin]!.fire();

            Future.delayed(const Duration(seconds: 6), () {

              resultOptions[spinTurn.spin]!.fire();

              var deviceFromOption = ref.read(rouletteListManagerProvider).getDeviceFromOption(spinTurn.spin);
              deviceFromOption.isOn = true;
              ref.read(lightTurnProvider(deviceFromOption).future).then((value) {
                // not much to do here
              });

              Future.delayed(const Duration(seconds: 5), () {
                resultBackOptions[spinTurn.spin]!.fire();

                Future.delayed(const Duration(seconds: 3), () {
                  introOptions[IntroOptions.intro]!.fire();

                  deviceFromOption.isOn = false;
                  ref.read(lightTurnProvider(deviceFromOption).future).then((value) {
                    // not much to do here
                  });
                });

              });
            });
          //}
      }
    ));
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

  void onRiveResultInit(Artboard ab) {

    resultSMController = StateMachineController.fromArtboard(
      ab, 'resultscreen')!;

    ab.addController(resultSMController);

    for(var value in RouletteOptions.values) {
      resultOptions[value] = resultSMController.findSMI(value.name) as SMITrigger;
      resultBackOptions[value] = resultSMController.findSMI('${value.name}back') as SMITrigger;
    }

    setState(() {
      isRiveInitialized = true;
    });
  }

  void onRiveIntroInit(Artboard ab) {

    introSMController = StateMachineController.fromArtboard(
      ab, 'mainintro')!;

    ab.addController(introSMController);

    for(var value in IntroOptions.values) {
      introOptions[value] = introSMController.findSMI(value.name) as SMITrigger;
    }

    setState(() {
      isRiveInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {

     return Stack(
      children: [
        Center(
          child: SizedBox(
            width: 500,
            height: 500,
            child: anim,
          ),
        ),
        Center(
          child: Transform.scale(
            alignment: Alignment.center,
            scale: 1.030,
            child: resultAnim
          ),
        ),
        Center(
          child: Transform.scale(
            alignment: Alignment.center,
            scale: 1.030,
            child: introAnim
          ),
        )
      ],
     );
  }
}