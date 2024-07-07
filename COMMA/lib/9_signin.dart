import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_plugin/user/user_pref.dart';
import 'package:get/get.dart';
import '16_homepage_move.dart';
import 'components.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import './api/api.dart';
import 'model/user.dart';

class FigmaToCodeApp9 extends StatelessWidget {
  const FigmaToCodeApp9({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        body: ListView(
          padding: const EdgeInsets.only(top: 0), // 여기서 top을 0으로 설정하여 상단 패딩을 제거
          children: const [
            SigninPage(),
          ],
        ),
      ),
    );
  }
}

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<User?> userLogin() async {
    try {
      var res = await http.post(
        Uri.parse('${API.baseUrl}/api/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_email': emailController.text.trim(),
          'user_password': passwordController.text.trim(),
        }),
      );

      if (res.statusCode == 200) {
        var resLogin = jsonDecode(res.body);
        print(resLogin);

        if (resLogin['success'] == true) {
          Fluttertoast.showToast(msg: 'login successfully');
          User userInfo = User.fromJson(resLogin['userData']);

          print("Login success");
          // await RememberUser.saveRememberUserInfo(userInfo);
          // Get.to(MainScreen());

          setState(() {
            emailController.clear();
            passwordController.clear();
          });
          return userInfo;
        } else {
          Fluttertoast.showToast(msg: 'Please check your email and password.');
          return null;
        }
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
      return null;
    }
    return null;
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
              SizedBox(height: size.height * 0.17), // 높이를 화면 높이의 10%로 설정
              const Text(
                '로그인',
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
                '로그인하고 오늘도\nCOMMA와 함께 힘차게 공부해요!',
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
                    SizedBox(height: size.height * 0.025),
                    InputButton(
                      label: 'Password',
                      obscureText: true,
                      controller: passwordController,
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.020),
              Checkbox2(
                label: '자동 로그인',
                onChanged: (bool value) {},
              ),
              SizedBox(height: size.height * 0.060),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: GestureDetector(
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      User? userInfo = await userLogin();
                      if (userInfo != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MainPage(userInfo: userInfo)),
                        );
                      }
                    }
                  },
                  child: Container(
                    width: size.width * 0.9,
                    height: size.height * 0.065,
                    decoration: ShapeDecoration(
                      color: const Color.fromRGBO(54, 174, 146, 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '로그인',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
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
