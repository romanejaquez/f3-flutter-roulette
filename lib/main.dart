import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_roulette/firebase_options.dart';
import 'package:flutter_roulette/widgets/roulette_wheel.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: const F3RouletteMain(),
    );
  }
}

class F3RouletteMain extends StatelessWidget {
  const F3RouletteMain({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF000230),
      body: Center(
        child: RouletteWheel(),
      ),
    );
  }
}