import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_plugin/user/user_pref.dart';
import 'package:get/get.dart';
import '16_homepage_move.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import 'api/api.dart';
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
          padding: EdgeInsets.only(top: 0), // 여기서 top을 0으로 설정하여 상단 패딩을 제거
          children: [
            SigninPage(),
          ],
        ),
      ),
    );
  }
}


class SigninPage extends StatefulWidget {
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
    try{
      var res = await http.post(
          Uri.parse(API.login),
          body: {
            'user_email' : emailController.text.trim(),
            'user_password' : passwordController.text.trim()
          });

      if(res.statusCode == 200){
        var resLogin = jsonDecode(res.body);

        if(resLogin['success'] == true){

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

        }else{
          Fluttertoast.showToast(msg: 'Please check your email and password.');
          return null;
        }
      }
    }catch(e){
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
              Text(
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
              Text(
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
              Checkbox1(label: '자동 로그인'),
              SizedBox(height: size.height * 0.060),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: GestureDetector(
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      User? userInfo = await userLogin();
                      if (userInfo != null){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MainPage(userInfo: userInfo)),
                        );
                      }
                    }
                  },
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

class InputButton extends StatelessWidget {
  final String label;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextEditingController controller;

  const InputButton({
    Key? key,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(left: size.width * 0.05),
      width: size.width,
      height: 50,
      child: Stack(
        children: [
          Positioned(
            right: size.width * 0.05,
            left: 0,
            top: 0,
            child: Container(
              width: 335,
              height: 50,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: Color(0xFF9FACBD)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Positioned.fill(
            left: 20,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '${label}',
                    hintStyle: TextStyle(color: Color(0xFF36AE92)),
                  ),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w500,
                  ),
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  validator: (value) { // Validator 추가
                    if (value == null || value.isEmpty) {
                      return '{$label} field cannot be empty';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Handle input changes if needed
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}