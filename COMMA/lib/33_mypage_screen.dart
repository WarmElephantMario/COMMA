import 'package:flutter/material.dart';
import 'components.dart';
import '34_profile_screen.dart';
import 'mypage/41_confirm_password_page.dart';
import 'mypage/42_help_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'model/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'api/api.dart';
import '1_Splash_green.dart';

// MyPageScreen 클래스 정의
class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildCard(BuildContext context, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEEEEEE), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: onTap,
          textColor: Colors.black,
        ),
      ),
    );
  }

  Future<void> deleteUser(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userKey = userProvider.user?.userKey;

    final response = await http.post(
      Uri.parse('${API.baseUrl}/api/delete_user'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'userKey': userKey}),
    );

    print(response.statusCode);
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
        Fluttertoast.showToast(msg: '회원 탈퇴가 완료되었습니다.');
        // SplashGreenScreen 화면으로 이동
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        Fluttertoast.showToast(msg: '회원 탈퇴 중 오류가 발생했습니다.');
      }
    } else {
      Fluttertoast.showToast(msg: '서버 오류: 회원 탈퇴 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            '마이페이지',
            style: TextStyle(
                color: Color.fromARGB(255, 48, 48, 48),
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700),
          ),
          iconTheme:
              const IconThemeData(color: Color.fromARGB(255, 48, 48, 48))),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 15),
          _buildCard(context, '프로필 정보', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()));
          }),
          _buildCard(context, '비밀번호 변경', () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ConfirmPasswordPage()));
          }),
          _buildCard(context, '도움말', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HelpPage()));
          }),
          _buildCard(context, '로그아웃', () {
            showConfirmationDialog(
              context,
              '로그아웃',
              '로그아웃 하시겠어요?',
              () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SplashScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            );
          }),
          _buildCard(context, '회원탈퇴', () {
            showConfirmationDialog(
              context,
              '회원탈퇴',
              '회원탈퇴 하시겠어요?',
              () async {
                await deleteUser(context);
              },
            );
          }),
        ],
      ),
      bottomNavigationBar:
          buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}
