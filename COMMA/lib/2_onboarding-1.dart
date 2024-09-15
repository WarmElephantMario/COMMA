import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_plugin/16_homepage_move.dart';
import 'package:flutter_plugin/api/api.dart';
import 'package:flutter_plugin/model/user.dart';
import 'package:flutter_plugin/model/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '3_onboarding-2.dart';
import '4_onboarding-3.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // jsonEncode를 사용하기 위한 라이브러리 임포트
import '10_typeselect.dart';

void main() {
  runApp(FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _setFocusToTop() {
    _focusNode.requestFocus();
  }

// DB에 새로운 사용자 정보 저장 후 userKey 반환
  Future<int> createUserInDB(String userId, String userNickname) async {
    final response = await http.post(
      Uri.parse('${API.baseUrl}/api/signup_info'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'user_nickname': userNickname,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['userKey']; // 서버에서 반환된 userKey
    } else {
      throw Exception('Failed to create user in DB');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return false; // 뒤로 가기 버튼을 눌렀을 때 아무 반응도 하지 않도록 설정
      },
      child: Scaffold(
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(), // 페이지 슬라이드 비활성화
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                  _setFocusToTop();
                });
              },
              children: [
                Onboarding1(),
                Onboarding2(focusNode: _focusNode),
                Onboarding3(focusNode: _focusNode),
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
                        Indicator(
                            active:
                                i == _currentPage), // 현재 페이지 인덱스에 따라 활성화 여부 결정
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Semantics(
                        sortKey: const OrdinalSortKey(1),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentPage > 0
                                ? Color.fromRGBO(54, 174, 146, 1.0)
                                : Colors.grey, // 비활성화된 버튼 배경색
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fixedSize: Size(size.width * 0.44,
                                size.height * 0.065), // 크기 설정
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
                              color: _currentPage > 0
                                  ? Colors.white
                                  : Colors.grey, // 텍스트 색상도 조정
                              fontSize: 14,
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Semantics(
                        sortKey: const OrdinalSortKey(2),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentPage < 2
                                ? Color.fromRGBO(54, 174, 146, 1.0)
                                : Colors.grey, // 비활성화된 버튼 배경색
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fixedSize: Size(size.width * 0.44,
                                size.height * 0.065), // 크기 설정
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
                              color: _currentPage < 2
                                  ? Colors.white
                                  : Colors.grey, // 텍스트 색상도 조정
                              fontSize: 14,
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Semantics(
                    sortKey: const OrdinalSortKey(3),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(
                            54, 174, 146, 1.0), // Background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fixedSize: Size(size.width * 0.9,
                            size.height * 0.065), // Button size
                      ),
                      onPressed: () async {
                        print('버튼 누름');
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String? userId =
                            prefs.getString('user_id'); // UUID를 user_id로 사용

                        if (userId == null) {
                          print('유저아이디 없음');
                          // userKey 없으면 새로 생성
                          userId = Uuid().v4(); // UUID 생성
                          print('Generated userId : $userId');

                          String userNickname = 'New User';
                          await prefs.setString('user_id', userId);
                          await prefs.setString('user_nickname', userNickname);

                          print('Generated user_id : $userId');
                          print('Generated user_nickname : $userNickname');

                          // DB에 새로운 사용자 정보 저장 후 userKey 받아옴
                          int userKey =
                              await createUserInDB(userId, userNickname);

                          // userKey를 로컬 저장소에 저장
                          await prefs.setInt('user_key', userKey);
                        }

                        // 로컬 저장소에서 userKey와 user_nickname 불러오기
                        int? userKey = prefs.getInt('user_key');
                        String? userNickname = prefs.getString('user_nickname');

                        if (userKey != null && userNickname != null) {
                          // UserProvider에 설정
                          Provider.of<UserProvider>(context, listen: false)
                              .setUser(
                                  User(userKey, userId!, userNickname, null));
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DisabilitySelectionPage()),
                        );
                      },
                      child: const Text(
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
                  ),
                ],
              ),
            ),
          ],
        ),
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
          const Text(
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
          const Text(
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
          Semantics(
            label: '학습하는 모습',
            child: SizedBox(
              width: size.width,
              height: size.height * 0.3,
              child: Image.asset('assets/onboarding_1.png'),
            ),
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
