import 'package:flutter/material.dart';
import 'components.dart';
import '34_profile_screen.dart';
import 'mypage/41_confirm_password_page.dart';
import 'mypage/42_help_page.dart';


// MyPageScreen 클래스 정의
class MyPageScreen extends StatefulWidget {
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
    return Card(
      elevation: 0.5,
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
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
              fontSize: 26, fontFamily: 'DM Sans', fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 15),
          _buildCard(context, '프로필 정보', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()));
          }),
          _buildCard(context, '비밀번호 변경', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ConfirmPasswordPage()));
          }),
          _buildCard(context, '도움말', () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HelpPage()));
          }),
          _buildCard(context, '로그아웃', () {
            showConfirmationDialog(
              context,
              '로그아웃',
              '로그아웃 하시겠어요?',
              
              () {
                // TODO: 로그아웃처리 후 처음시작화면으로 이동
              },
            );
          }),
          _buildCard(context, '회원탈퇴', () {
            showConfirmationDialog(
              context,
              '회원탈퇴',
              '회원탈퇴 하시겠어요?',
              
              () {
                // TODO: 회원탈퇴처리 후 처음시작화면으로 이동
              },
            );
          }),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}
