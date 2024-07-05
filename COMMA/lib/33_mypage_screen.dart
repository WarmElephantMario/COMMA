import 'package:flutter/material.dart';
import '34_profile_screen.dart';
import 'mypage/41_confirm_password_page.dart';
import 'mypage/42_help_page.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  void _showConfirmationDialog(BuildContext context, String title,
      String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFFFFA17A))),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text('확인',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF545454))),
            ),
          ],
        );
      },
    );
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
            _showConfirmationDialog(
              context,
              '로그아웃',
              '정말 로그아웃 하시겠습니까?',
              () {
                // TODO: 로그아웃처리 후 처음시작화면으로 이동
              },
            );
          }),
          _buildCard(context, '회원탈퇴', () {
            _showConfirmationDialog(
              context,
              '회원탈퇴',
              '정말 회원탈퇴 하시겠습니까?',
              () {
                // TODO: 회원탈퇴처리 후 처음시작화면으로 이동
              },
            );
          }),
        ],
      ),
    );
  }
}
