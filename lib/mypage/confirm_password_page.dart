import 'package:flutter/material.dart';
import 'change_password_page.dart';

class ConfirmPasswordPage extends StatelessWidget {
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('비밀번호 확인'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
          child: Column(
            children: [
              Text(
                '개인정보를 안전하게 보호하기 위해서\n비밀번호를 다시 한번 확인합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF585858)),
              ),
              SizedBox(height: 40),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  enabledBorder: InputBorder.none,
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF585858))),
                  filled: true,
                  fillColor: Color(0xFFEDFDF8),
                  labelText: '비밀번호를 입력해주세요.',
                  labelStyle: TextStyle(color: Color(0xFF585858)),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 50),
              TextButton(
                onPressed: () {
                  // TODO : 비밀번호 확인 로직 구현
                  // 비밀번호가 일치할 시에만 변경 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                  );
                },
                child: Text('확인', style: TextStyle(color: Colors.white)),
                style: TextButton.styleFrom(
                  maximumSize: Size(240, 55),
                  minimumSize: Size(240, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Color(0xFF167F71),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
