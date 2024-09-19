import 'package:flutter/material.dart';
import 'package:flutter_plugin/components.dart';
import '40_change_password_page.dart';
import '../model/44_font_size_provider.dart';
import 'package:provider/provider.dart';



class ConfirmPasswordPage extends StatefulWidget {
  const ConfirmPasswordPage({super.key});

  @override
  _ConfirmPasswordPageState createState() => _ConfirmPasswordPageState();
}

class _ConfirmPasswordPageState extends State<ConfirmPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 폰트 크기 비율을 Provider에서 가져옴
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    // 디스플레이 비율을 가져옴
    final scaleFactor = fontSizeProvider.scaleFactor;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 48, 48, 48)),
        title: const Text(
          '비밀번호 확인',
          style: TextStyle(
              color: Color.fromARGB(255, 48, 48, 48),
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
          child: Column(
            children: [
              Text(
                '개인정보를 안전하게 보호하기 위해서\n비밀번호를 다시 한번 확인합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16* scaleFactor, color: Color(0xFF585858)),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  enabledBorder: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF585858))),
                  filled: true,
                  fillColor: Color(0xFFEDFDF8),
                  labelText: '비밀번호를 입력해주세요.',
                  labelStyle: TextStyle(color: Color(0xFF585858)),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 50),
              ClickButton(
                text: '확인',
                onPressed: () {
                  // TODO : 비밀번호 확인 로직 구현
                  // 비밀번호가 일치할 시에만 변경 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage()),
                  );
                },
                width: MediaQuery.of(context).size.width * 0.5, // 원하는 너비 설정
                height: 50.0, // 원하는 높이 설정
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}
