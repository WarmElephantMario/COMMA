import 'package:flutter/material.dart';

class Onboarding2 extends StatelessWidget {
  final FocusNode focusNode;

  const Onboarding2({required this.focusNode});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Focus(
        focusNode: focusNode,
        child: Container(
          width: size.width,
          height: size.height,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.20),
              const Text(
                '자동으로 대체텍스트를 생성해요.',
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
                '강의 자료를 미리 업로드하기만 하면,\nCOMMA가 자동으로 대체텍스트를 생성해요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF245B3A),
                  fontSize: 14,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: size.height * 0.08),
              Semantics(
                label: '대체텍스트 생성',
                child: SizedBox(
                  width: size.width,
                  height: size.height * 0.3,
                  child: Image.asset('assets/onboarding_2.png'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
