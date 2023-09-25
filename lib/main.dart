import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_roulette/firebase_options.dart';
import 'package:flutter_roulette/providers.dart';
import 'package:flutter_roulette/widgets/roulette_wheel.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart';
import 'dart:math' as math;

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ProviderScope(child: F3RouletteApp()));
}

class F3RouletteApp extends StatelessWidget {
  const F3RouletteApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(),
      routeInformationProvider: AppRoutes.router.routeInformationProvider,
      routeInformationParser: AppRoutes.router.routeInformationParser,
      routerDelegate: AppRoutes.router.routerDelegate,
    );
  }
}

class AppRoutes {
  
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
            return const F3RouletteMain();
        },
      ),

      GoRoute(
        path: '/ctrl',
        builder: (context, state) {
            return const FlutterRouletteBtnPage();
        },
      ),
      
    ]
  );
}

class F3RouletteMain extends ConsumerWidget {
  const F3RouletteMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final rouletteDevices = ref.watch(rouletteDevicesProvider);

    return Scaffold(
      backgroundColor: Color(0xFF000230),
      body: rouletteDevices.when(
        data: (devicesList) {

          ref.read(rouletteListManagerProvider).initializeList(devicesList);
          
          return  Center(
            child: RouletteWheel(),
          );
        },
        loading: () => Text("loading"),
        error: (error, stackTrace) => Text('Error'),
      ),
    );
  }
}

class FlutterRouletteButton extends StatefulWidget {

  final Function onPress;
  const FlutterRouletteButton({
    required this.onPress,
    super.key});

  @override
  State<FlutterRouletteButton> createState() => _FlutterRouletteButtonState();
}

class FlutterRouletteBtnPage extends ConsumerWidget {
  const FlutterRouletteBtnPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF00338A),
      body: Center(
        child: SizedBox(
          width: 350,
          height: 350,
          child: FlutterRouletteButton(
            onPress: () {
              ref.read(dbProvider).collection('roulette-events').doc('roulette-spins').set({
                  'spin': Random().nextInt(8).floor(),
                  'timestamp': DateTime.now().toIso8601String(),
                }, SetOptions(merge: true));
            },
          ),
        ),
      ),
    );
  }
}

class _FlutterRouletteButtonState extends State<FlutterRouletteButton> {

  late RiveAnimation anim;
  late StateMachineController ctrl;
  late SMITrigger inputTrigger;

  @override
  void initState() {
    super.initState();

    anim = RiveAnimation.asset('./assets/anims/flappydash_ctrl.riv',
      artboard: 'spinbtn',
      onInit: onRiveInit,
      fit: BoxFit.contain,
    );
  }

  void onRiveInit(Artboard ab) {
    ctrl = StateMachineController.fromArtboard(ab, 'spinbtn')!;

    ab.addController(ctrl);
    inputTrigger = ctrl.findSMI('press')! as SMITrigger;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown:(details) {
    inputTrigger.fire();
        },
        onTap: () {
    widget.onPress();
        },
        child: anim,
      );
  }
}