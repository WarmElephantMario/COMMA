import 'package:flutter/material.dart';
import '3_onboarding-2.dart';
import '5_Signup.dart';

void main() {
  runApp(FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromRGBO(54, 174, 146, 1.0),
      ),
      home: OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          Onboarding1(_pageController),
          Onboarding2(),
          SignUpPage(),
        ],
      ),
    );
  }
}

class Onboarding1 extends StatelessWidget {
  final PageController controller;

  Onboarding1(this.controller);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      color: Colors.white,
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: size.height * 0.13), // 높이를 화면 높이의 10%로 설정
              Text(
                '더 정확한 자막을 실시간으로 제공해요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                'COMMA는 강의 자료를 학습하여\n실시간 수업 중에 더 정확한 자막을 생성해요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF245B3A),
                  fontSize: 14,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                ),
              ),

              Container(
                width: size.width * 0.250,
                height: size.height * 0.060,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Opacity(
                      opacity: 0.35,
                      child: Container(
                        width: size.width * 0.06,
                        height: size.height * 0.008,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: size.width * 0.0013),
                            borderRadius: BorderRadius.circular(size.width * 0.008),
                          ),
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.35,
                      child: Container(
                        width: size.width * 0.06,
                        height: size.height * 0.008,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: size.width * 0.0013),
                            borderRadius: BorderRadius.circular(size.width * 0.008),
                          ),
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.35,
                      child: Container(
                        width: size.width * 0.06,
                        height: size.height * 0.008,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: size.width * 0.0013),
                            borderRadius: BorderRadius.circular(size.width * 0.008),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.08),
              Container(
                width: size.width,
                height: size.height * 0.3,
                child: Image.asset('assets/onboarding_1.png'),
              ),
              SizedBox(height: size.height * 0.10),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Container(
                  width: size.width * 0.9,
                  height: size.height * 0.065,
                  decoration: ShapeDecoration(
                    color: Color.fromRGBO(54, 174, 146, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // 다음 페이지로 이동
                          controller.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        },
                        child: Text(
                          '다음',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.005),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Container(
                  width: size.width * 0.9,
                  height: size.height * 0.065,
                  decoration: ShapeDecoration(
                    color: Color.fromRGBO(54, 174, 146, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => FigmaToCodeApp()),
                          );
                        },
                        child: Text(
                          '바로 시작하기',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(flex: 2),
            ],
          ),

        ],
      ),
    );
  }
}

