import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_plugin/api/api.dart';
import 'package:flutter_plugin/model/user.dart';
import 'package:get/get.dart';
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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        body: ListView(
          padding: EdgeInsets.only(top: 0), // 여기서 top을 0으로 설정하여 상단 패딩을 제거
          children: [
            SignUpPage(),
          ],
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<bool> checkUserPhone() async {
    try {
      var response = await http.post(
          Uri.parse('${API.baseUrl}/api/validate_phone'),
          headers: {
            'Content-Type': 'application/json',
          },
        body: jsonEncode({
          'user_phone': phoneController.text.trim()
        }),
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);

        if (responseBody['existPhone'] == true) {
          Fluttertoast.showToast(msg: "This phone number is already in use.");
          return false;
        } else {
          print('validation success');
          saveInfo();
          return true;
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
    User userModel = User(
      1,
      emailController.text.trim(),
      phoneController.text.trim(),
      passwordController.text.trim(),
    );

    try {
      var res = await http.post(
        Uri.parse('${API.baseUrl}/api/signup_info'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userModel.toJson()),
      );

      if (res.statusCode == 200) {
        var resSignup = jsonDecode(res.body);
        if (resSignup['success'] == true) {
          Fluttertoast.showToast(msg: 'Signup successfully');
          setState(() {
            emailController.clear();
            passwordController.clear();
            phoneController.clear();
          });
        } else {
          Fluttertoast.showToast(msg: 'Error occurred. Please try again.');
        }
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
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
              Text(
                '계정 생성하기',
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
                '계정 생성을 위해 필요한 정보를\n정확히 입력해 주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF245B3A),
                  fontSize: 14,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: size.height * 0.050),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    InputButton(
                      label: 'Email address',
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                    ),
                    SizedBox(height: size.height * 0.035),
                    InputButton(
                      label: 'Password',
                      obscureText: true,
                      controller: passwordController,
                    ),
                    SizedBox(height: size.height * 0.035),
                    InputButton(
                      label: 'Phone number',
                      keyboardType: TextInputType.phone,
                      controller: phoneController,
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.060),

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
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              bool isPhoneValid = await checkUserPhone();
                              if (isPhoneValid) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Verification_screen()),
                                );
                              }else{
                                print("인증 실패함");
                              }
                            }
                          },
                          child: Text(
                            '인증코드 전송하기',
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

              SizedBox(
                height: 120,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '이미 계정이 있으신가요?',
                    style: TextStyle(
                      color: Color(0xFF36AE92),
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w500,
                      height: 0.11,
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FigmaToCodeApp9()),
                      );
                    },
                    child: Text(
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
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '비밀번호를 잊으셨나요?',
                    style: TextStyle(
                      color: Color(0xFF36AE92),
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w500,
                      height: 0.11,
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      // 비밀번호 찾기 화면 추가로 구현해야 함
                      print('비밀번호 찾기 버튼이 클릭되었습니다.');
                    },
                    child: Text(
                      '비밀번호 찾기',
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
