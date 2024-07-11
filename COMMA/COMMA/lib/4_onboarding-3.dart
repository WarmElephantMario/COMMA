import 'package:flutter/material.dart';
import '5_Signup.dart';

class Onboarding3 extends StatelessWidget {
  const Onboarding3({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: size.height * 0.20),
          const Text(
            'AI가 만드는 대체 학습 자료 콜론(:)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          const Text(
            '수업 후에도 편하게 복습할 수 있도록,\nAI가 학습자 맞춤형 대체 학습 자료를 만들어 드려요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF245B3A),
              fontSize: 14,
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: size.height * 0.08),
          SizedBox(
            width: size.width,
            height: size.height * 0.3,
            child: Image.asset('assets/onboarding_3.png'),
          ),
        ],
      ),
    );
  }
}
