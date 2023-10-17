import 'package:assets_audio_player/assets_audio_player.dart';
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
  late RiveAnimation qrcodeAnim;
  late RiveAnimation winConfettiAnim;


  late StateMachineController smController;
  late StateMachineController resultSMController;
  late StateMachineController introSMController;
  late StateMachineController dashConfettiControler;


  Map<RouletteOptions, SMITrigger> rouletteOptions = {};
  Map<RouletteOptions, SMITrigger> resultOptions = {};
  Map<RouletteOptions, SMITrigger> resultBackOptions = {};
  Map<IntroOptions, SMITrigger> introOptions = {};
  late SMITrigger dashConfettiTrigger;
  late SMITrigger sparkyConfettiTrigger;

  SMITrigger? showQRCodeTrigger;
  SMITrigger? hideQRCodeTrigger;

  bool isRiveInitialized = false;
  bool isResultRiveInitialized = false;
  RouletteSpin spinTurn = RouletteSpin(spin: RouletteOptions.flutter1, timeStamp: DateTime.now());
  bool isWheelSpinning = false;
  bool showQRCode = false;

  AssetsAudioPlayer bigWinPlayer = AssetsAudioPlayer();
  AssetsAudioPlayer simpleWinPlayer = AssetsAudioPlayer();
  AssetsAudioPlayer spinningPlayer = AssetsAudioPlayer();

  String rivPath = 'assets/anims/flutterconflatam_roulette.riv';

  @override
  void initState() {
    super.initState();

    // initialize sound
    bigWinPlayer.open(Audio('/assets/sounds/big_win.mp3'), autoStart: false);
    simpleWinPlayer.open(Audio('/assets/sounds/simple_win.mp3'), autoStart: false);
    spinningPlayer.open(Audio('/assets/sounds/spinning_sound.mp3'), autoStart: false);

    anim = RiveAnimation.asset(
      rivPath,
      artboard: 'roulette',
      onInit: onRiveInit,
      fit: BoxFit.contain,
    );

    resultAnim = RiveAnimation.asset(
      rivPath,
      artboard: 'resultscreen',
      onInit: onRiveResultInit,
      fit: BoxFit.fitHeight,
    );

    introAnim = RiveAnimation.asset(
      rivPath,
      artboard: 'mainintro',
      onInit: onRiveIntroInit,
      fit: BoxFit.fitHeight,
    );

    winConfettiAnim = RiveAnimation.asset(
      'assets/anims/flutterdash.riv',
      artboard: 'winconfetti',
      onInit: onRiveDashConfettiInit,
      fit: BoxFit.fitHeight,
    );

    ref.read(rouletteProvider((RouletteSpin streamData) {

        if (isWheelSpinning) {
          return;
        }

        setState(() {
          spinTurn = streamData;
          isWheelSpinning = true;
          showQRCode = false;

          if (hideQRCodeTrigger != null) {
            hideQRCodeTrigger!.fire();
          }
        });

        introOptions[IntroOptions.outro]!.fire();
        rouletteOptions[spinTurn.spin]!.fire();
        spinningPlayer.play();

        Future.delayed(const Duration(seconds: 6), () {

          resultOptions[spinTurn.spin]!.fire();

          var deviceFromOption = ref.read(rouletteListManagerProvider).getDeviceFromOption(spinTurn.spin);
          deviceFromOption.isOn = true;

          ref.read(lightTurnProvider(deviceFromOption).future).then((value) {
            // not much to do here
          });

          if (spinTurn.spin == RouletteOptions.firebase1 || spinTurn.spin == RouletteOptions.firebase2 || spinTurn.spin == RouletteOptions.flutter1 || spinTurn.spin == RouletteOptions.flutter2)
          {
            bigWinPlayer.play();
            if (spinTurn.spin == RouletteOptions.firebase1 || spinTurn.spin == RouletteOptions.firebase2) {
              sparkyConfettiTrigger.fire();
            }
            else if (spinTurn.spin == RouletteOptions.flutter1 || spinTurn.spin == RouletteOptions.flutter2) {
              dashConfettiTrigger.fire();
            }

            // setState(() {
            //   showQRCode = true;

            //   if (showQRCodeTrigger != null) {
            //     showQRCodeTrigger!.fire();
            //   }
            // });
          }
          else {
            simpleWinPlayer.play();
          }

          Future.delayed(const Duration(seconds: 5), () {
            resultBackOptions[spinTurn.spin]!.fire();

            Future.delayed(const Duration(seconds: 3), () {
              introOptions[IntroOptions.intro]!.fire();

              deviceFromOption.isOn = false;
              ref.read(lightTurnProvider(deviceFromOption).future).then((value) {
                // not much to do here
              });

              if (showQRCode == true) {
                Future.delayed(const Duration(seconds: 8), () {
                  setState(() {
                    showQRCode = false;

                    if (hideQRCodeTrigger != null) {
                      hideQRCodeTrigger!.fire();
                    }

                    isWheelSpinning = false;
                  });
                });
              }
              else {
                isWheelSpinning = false;
              }
            });

          });
        });
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

  void onRiveDashConfettiInit(Artboard ab) {

    dashConfettiControler = StateMachineController.fromArtboard(
      ab, 'winconfetti')!;

    ab.addController(dashConfettiControler);
    dashConfettiTrigger = dashConfettiControler.findSMI('dashconfetti') as SMITrigger;
    sparkyConfettiTrigger = dashConfettiControler.findSMI('sparkyconfetti') as SMITrigger;
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

  void onRiveQRCodeScanInit(Artboard ab) {

    smController = StateMachineController.fromArtboard(
      ab, 'qrcodepanelroulette')!;

    ab.addController(smController);
    showQRCodeTrigger = smController.findSMI('qrcodein') as SMITrigger;
    hideQRCodeTrigger = smController.findSMI('qrcodeout') as SMITrigger;

    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {

     return Stack(
      children: [
        Center(
          child: anim,
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
        ),

        Align(alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            widthFactor: 1,
            heightFactor: 0.7,
            child: winConfettiAnim)
        ),
        
      ],
     );
  }
}