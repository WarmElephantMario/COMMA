import 'package:flutter/material.dart';
import 'components.dart';
import '8_verification3.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'api/api.dart';
import 'model/user.dart';
import 'dart:math';

class Verification_write_screen extends StatelessWidget {
  final String userEmail; // 추가된 부분
  final String userId; // 추가된 부분
  final String userPassword; // 추가된 부분

  const Verification_write_screen({
    super.key,
    required this.userEmail, // 추가된 부분
    required this.userId, // 추가된 부분
    required this.userPassword, // 추가된 부분
  });

  Future<void> _verifyAndSignup(BuildContext context, String verificationCode) async {
    try {
      var response = await http.post(
        Uri.parse('${API.baseUrl}/api/verify_code'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_email': userEmail,
          'verification_code': verificationCode,
        }),
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);

        if (responseBody['success']) {
          // 인증 성공 시 회원가입 정보 저장
          String randomNickname = generateRandomNickname();

          User userModel = User(
            1,
            userId,
            userEmail,
            userPassword,
            randomNickname,
          );

          var signupResponse = await http.post(
            Uri.parse('${API.baseUrl}/api/signup_info'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(userModel.toJson()),
          );

          print('Request body: ${jsonEncode(userModel.toJson())}');
          print('Response status: ${signupResponse.statusCode}');
          print('Response body: ${signupResponse.body}');

          if (signupResponse.statusCode == 200) {
            var signupResponseBody = jsonDecode(signupResponse.body);
            if (signupResponseBody['success'] == true) {
              Fluttertoast.showToast(msg: 'Signup successfully');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Verification_Complete_screen(),
                ),
              );
            } else {
              Fluttertoast.showToast(msg: 'Error occurred. Please try again.');
            }
          } else {
            Fluttertoast.showToast(msg: 'Error: ${signupResponse.statusCode}');
          }
        } else {
          Fluttertoast.showToast(msg: 'Invalid verification code.');
        }
      } else {
        Fluttertoast.showToast(msg: 'Verification failed.');
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
    }
  }

  String generateRandomNickname() {
    const adjectives = [
      "짱멋진", "성실한", "용감한", "힘찬", "다정한", "밝은", "행복한", "씩씩한", "진지한", "유쾌한", "즐거운", "똑똑한",
      "솔직한", "온화한", "강한", "상냥한", "따뜻한", "열정적인", "활기찬", "근면한", "눈부신", "친절한", "충실한", "차분한",
      "훈훈한", "강인한", "열정가득", "행복가득", "참신한", "당당한", "맑은", "희망찬", "강력한", "부지런한", "긍정적인",
      "명랑한", "순수한"
    ];
    const nouns = [
      "짜빠구리", "고등어", "눈사람", "사자", "호랑이", "독수리", "코끼리", "팬더", "고래", "돌고래", "늑대", "독수리",
      "코알라", "부엉이", "고양이", "강아지", "햄스터", "다람쥐", "원숭이", "앵무새", "바나나", "파인애플", "복숭아",
      "오렌지", "토마토", "브로콜리", "고구마", "시금치", "콩나물", "해바라기", "코스모스", "민들레", "진달래"
    ];
    final random = Random();

    final adjective = adjectives[random.nextInt(adjectives.length)];
    final noun = nouns[random.nextInt(nouns.length)];

    return "$adjective $noun";
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController codeController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF36AE92),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 0),
        children: [
          Information(
            userEmail: userEmail, // 추가된 부분
            userId: userId, // 추가된 부분
            userPassword: userPassword, // 추가된 부분
            codeController: codeController, // 추가된 부분
            onVerifyAndSignup: () => _verifyAndSignup(context, codeController.text), // 추가된 부분
          ),
        ],
      ),
    );
  }
}

class Information extends StatelessWidget {
  final String userEmail; // 추가된 부분
  final String userId; // 추가된 부분
  final String userPassword; // 추가된 부분
  final TextEditingController codeController; // 추가된 부분
  final VoidCallback onVerifyAndSignup; // 추가된 부분

  const Information({
    super.key,
    required this.userEmail, // 추가된 부분
    required this.userId, // 추가된 부분
    required this.userPassword, // 추가된 부분
    required this.codeController, // 추가된 부분
    required this.onVerifyAndSignup, // 추가된 부분
  });

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
              SizedBox(height: size.height * 0.10),
              const Text(
                '인증코드',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              const Text(
                '계정 생성에 사용한 이메일 주소로\n인증코드가 발송되었습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF245B3A),
                  fontSize: 14,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: size.height * 0.07),
              InputButton(
                label: '인증코드를 입력해주세요',
                keyboardType: TextInputType.emailAddress,
                controller: codeController, // 수정된 부분
              ),
              SizedBox(height: size.height * 0.07),
              ClickButton(
                text: '인증 완료하기',
                onPressed: onVerifyAndSignup, // 수정된 부분
              ),
              const SizedBox(height: 200),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '이미 계정이 있으신가요?',
                    style: TextStyle(
                      color: Color(0xFF36AE92),
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w500,
                      height: 0.11,
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      // TODO: 로그인 화면으로 네비게이션 코드 추가
                      print('로그인 버튼이 클릭되었습니다.');
                    },
                    child: const Text(
                      '로그인',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
