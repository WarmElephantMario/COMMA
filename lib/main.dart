import 'package:flutter/material.dart';
import '1_Splash_green.dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromRGBO(54, 174, 146, 1.0),
      ),
      home: Scaffold(
        body: SplashScreen(),
      ),
    );
  }
}
