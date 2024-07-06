import 'package:flutter/material.dart';
import '3_onboarding-2.dart';
import '4_onboarding-3.dart';
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
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(), // 페이지 슬라이드 비활성화
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              Onboarding1(),
              Onboarding2(),
              Onboarding3(),
            ],
          ),
          Positioned(
            bottom: 50.0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < 3; i++) // 페이지 개수에 따라 수정
                      Indicator(active: i == _currentPage), // 현재 페이지 인덱스에 따라 활성화 여부 결정
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentPage > 0 ? Color.fromRGBO(54, 174, 146, 1.0) : Colors.grey, // 비활성화된 버튼 배경색
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fixedSize: Size(size.width * 0.44, size.height * 0.065), // 크기 설정
                      ),
                      onPressed: _currentPage > 0
                          ? () {
                        _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                          : null, // 0페이지일 때 onPressed에 null 할당하여 비활성화
                      child: Text(
                        '이전',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _currentPage > 0 ? Colors.white : Colors.grey, // 텍스트 색상도 조정
                          fontSize: 14,
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    SizedBox( width: 10, ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentPage < 2 ? Color.fromRGBO(54, 174, 146, 1.0) : Colors.grey, // 비활성화된 버튼 배경색
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fixedSize: Size(size.width * 0.44, size.height * 0.065), // 크기 설정
                      ),
                      onPressed: _currentPage < 2 // 마지막 페이지에서는 비활성화
                          ? () {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                          : null,
                      child: Text(
                        '다음',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _currentPage < 2 ? Colors.white : Colors.grey, // 텍스트 색상도 조정
                          fontSize: 14,
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 5,),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(54, 174, 146, 1.0), // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fixedSize: Size(size.width * 0.9, size.height * 0.065), // Button size
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FigmaToCodeApp5()),
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Onboarding1 extends StatelessWidget {
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
          SizedBox(height: size.height * 0.20), // 위쪽 여백 추가
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
          SizedBox(height: size.height * 0.08),
          Container(
            width: size.width,
            height: size.height * 0.3,
            child: Image.asset('assets/onboarding_1.png'),
          ),
        ],
      ),
    );
  }
}


class Indicator extends StatelessWidget {
  final bool active;

  Indicator({this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? Color.fromRGBO(54, 174, 146, 1.0) : Colors.grey,
      ),
    );
  }
}

