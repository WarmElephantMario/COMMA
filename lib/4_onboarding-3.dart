import 'package:flutter/material.dart';
import '5_Signup.dart';


class _Onboarding4 extends StatelessWidget {
  const _Onboarding4({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        body: ListView(
          padding: EdgeInsets.only(top: 0), // 여기서 top을 0으로 설정하여 상단 패딩을 제거
          children: [
            Onboarding4(),
          ],
        ),
      ),
    );
  }
}

class Onboarding4 extends StatelessWidget {
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
              SizedBox(height: size.height * 0.17), // 높이를 화면 높이의 10%로 설정
              Text(
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
              Text(
                '수업 후에도 편하게 복습할 수 있도록,\nAI가 학습자 맞춤형 대체 학습 자료를 만들어 드려요.',
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
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Opacity(
                        opacity: 0.35,
                        child: Container(
                          width: size.width * 0.06,
                          height: size.height * 0.008,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: size.width * 0.0013),
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.008),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Opacity(
                        opacity: 0.35,
                        child: Container(
                          width: size.width * 0.06,
                          height: size.height * 0.008,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: size.width * 0.0013),
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.008),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Opacity(
                        opacity: 0.35,
                        child: Container(
                          width: size.width * 0.06,
                          height: size.height * 0.008,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: size.width * 0.0013),
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.008),
                            ),
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
                child: Image.asset('assets/onboarding_3.png'),
              ),
              SizedBox(height: size.height * 0.11),
              SizedBox(height: size.height * 0.065),
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
                          Navigator.push(
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
            ],
          ),
        ],
      ),
    );
  }
}