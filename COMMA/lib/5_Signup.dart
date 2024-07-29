import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_plugin/api/api.dart';
import 'package:flutter_plugin/model/user.dart';
import '6_verification.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import '9_signin.dart';
import 'components.dart';

class FigmaToCodeApp5 extends StatelessWidget {
  const FigmaToCodeApp5({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        body: ListView(
          padding: const EdgeInsets.only(top: 0), // 여기서 top을 0으로 설정하여 상단 패딩을 제거
          children: const [
            SignUpPage(),
          ],
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController idController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String generateRandomNickname() {
    const adjectives = [
      "짱멋진",
      "성실한",
      "용감한",
      "힘찬",
      "다정한",
      "밝은",
      "행복한",
      "씩씩한",
      "진지한",
      "유쾌한",
      "즐거운",
      "똑똑한",
      "솔직한",
      "온화한",
      "강한",
      "상냥한",
      "따뜻한",
      "열정적인",
      "활기찬",
      "근면한",
      "눈부신",
      "친절한",
      "충실한",
      "차분한",
      "훈훈한",
      "강인한",
      "열정가득",
      "행복가득",
      "참신한",
      "당당한",
      "맑은",
      "희망찬",
      "강력한",
      "부지런한",
      "긍정적인",
      "명랑한",
      "순수한"
    ];
    const nouns = [
      "짜빠구리",
      "고등어",
      "눈사람",
      "사자",
      "호랑이",
      "독수리",
      "코끼리",
      "팬더",
      "고래",
      "돌고래",
      "늑대",
      "독수리",
      "코알라",
      "부엉이",
      "고양이",
      "강아지",
      "햄스터",
      "다람쥐",
      "원숭이",
      "앵무새",
      "바나나",
      "파인애플",
      "복숭아",
      "오렌지",
      "토마토",
      "브로콜리",
      "고구마",
      "시금치",
      "콩나물",
      "해바라기",
      "코스모스",
      "민들레",
      "진달래"
    ];
    final random = Random();

    final adjective = adjectives[random.nextInt(adjectives.length)];
    final noun = nouns[random.nextInt(nouns.length)];

    return "$adjective $noun";
  }

  Future<bool> checkUserEmail() async {
    try {
      var response = await http.post(
        Uri.parse('${API.baseUrl}/api/validate_email'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'user_email': emailController.text.trim()}),
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);

        if (responseBody['existEmail'] == true) {
          Fluttertoast.showToast(msg: "This Email Address is already in use.");
          return false;
        } else {
          print('validation success');

          //saveInfo();

          // 이메일 인증번호 전송 API 호출
          var emailResponse = await http.post(
            Uri.parse('${API.baseUrl}/api/send_verification_code'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'user_email': emailController.text.trim()}),
          );

          print(emailResponse.statusCode);
          if (emailResponse.statusCode == 200) {
            // 인증번호 전송 완료 화면으로 이동
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => Verification_screen(
            //       userEmail: emailController.text.trim(),
            //       userId: idController.text.trim(),
            //       userPassword: passwordController.text.trim(),
            //   )),
            // );
            return true;
          } else {
            Fluttertoast.showToast(msg: '인증번호 전송에 실패했습니다.');
            return false;
          }
        }
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
      return false;
    }
    return false;
  }

  Future<void> saveInfo() async {
    String randomNickname = generateRandomNickname();

    User userModel = User(
      1,
      idController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
      randomNickname,
    );

    try {
      var res = await http.post(
        Uri.parse('${API.baseUrl}/api/signup_info'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userModel.toJson()),
      );

      print('Request body: ${jsonEncode(userModel.toJson())}'); // 요청 데이터 출력

      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');

      if (res.statusCode == 200) {
        var resSignup = jsonDecode(res.body);
        if (resSignup['success'] == true) {
          Fluttertoast.showToast(msg: 'Signup successfully');
          setState(() {
            idController.clear();
            emailController.clear();
            passwordController.clear();
          });
        } else {
          Fluttertoast.showToast(msg: 'Error occurred. Please try again.');
        }
      } else {
        Fluttertoast.showToast(msg: 'Error: ${res.statusCode}');
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    idController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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
              SizedBox(height: size.height * 0.17), // 높이를 화면 높이의 17%로 설정
              Semantics(
                sortKey: OrdinalSortKey(1.0),
                child: const Text(
                  '계정 생성하기',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Semantics(
                sortKey: OrdinalSortKey(2.0),
                child: const Text(
                  '계정 생성을 위해 필요한 정보를\n정확히 입력해 주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF245B3A),
                    fontSize: 14,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.050),
              Semantics(
                sortKey: OrdinalSortKey(3.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      InputButton(
                        label: '아이디',
                        keyboardType: TextInputType.name,
                        controller: idController,
                      ),
                      SizedBox(height: size.height * 0.035),
                      InputButton(
                        label: '비밀번호',
                        obscureText: true,
                        controller: passwordController,
                      ),
                      SizedBox(height: size.height * 0.035),
                      InputButton(
                        label: '이메일',
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.060),
              Semantics(
                sortKey: OrdinalSortKey(4.0),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: Container(
                    width: size.width * 0.9,
                    height: size.height * 0.065,
                    decoration: ShapeDecoration(
                      color: const Color.fromRGBO(54, 174, 146, 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          bool isEmailValid = await checkUserEmail();
                          if (isEmailValid) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Verification_screen(
                                        userEmail: emailController.text.trim(),
                                        userId: idController.text.trim(),
                                        userPassword:
                                            passwordController.text.trim(),
                                      )),
                            );
                          } else {
                            print("인증 실패함");
                          }
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '인증코드 전송하기',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 70,
              ),
              Semantics(
                sortKey: OrdinalSortKey(5.0),
                child: Row(
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SigninPage()),
                        );
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
