// splash_screen.dart
import 'package:flutter/material.dart';
import '2_onboarding-1.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to Onboarding1 after 5 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FigmaToCodeApp()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the size of the screen
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Container(
          width: size.width * 0.3, // Adjust this value to change logo size
          height: size.width * 0.3, // Maintain aspect ratio
          decoration: const BoxDecoration(
            color: Colors.green,
            image: DecorationImage(
              image: AssetImage('assets/logo_white.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
