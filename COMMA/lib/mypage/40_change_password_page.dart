import 'package:flutter/material.dart';
import 'package:flutter_plugin/components.dart';
import '../model/44_font_size_provider.dart';
import 'package:provider/provider.dart';


class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
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

    return WillPopScope(
    onWillPop: () async {
      return false; // 뒤로 가기 버튼을 눌렀을 때 아무 반응도 하지 않도록 설정
    },
    child:  Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 48, 48, 48)),
        title: const Text(
          '비밀번호 변경',
          style: TextStyle(
              color: Color.fromARGB(255, 48, 48, 48),
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '새로운 비밀번호를 입력해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16 * scaleFactor , color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '8자 이상 영문,숫자,특수문자 포함',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ClickButton(
              text: '확인',
              onPressed: () {
                // Here, update the password
                // Provide feedback to the user
              },
              width: MediaQuery.of(context).size.width * 0.5, // 원하는 너비 설정
              height: 50.0, // 원하는 높이 설정
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    ),
    );
  }
}
