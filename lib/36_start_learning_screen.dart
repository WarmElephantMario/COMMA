import 'package:flutter/material.dart';

class StartLearningScreen extends StatelessWidget {
  const StartLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '학습 시작',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    );
  }
}
