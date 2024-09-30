import 'package:flutter/material.dart';
import 'package:flutter_plugin/components.dart';
import '../model/44_font_size_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '44_font_size_page.dart';

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
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        return false; // 뒤로 가기 버튼을 눌렀을 때 아무 반응도 하지 않도록 설정
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          iconTheme: IconThemeData(color: theme.colorScheme.onTertiary),
          title: Text(
            '비밀번호 변경',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                '새로운 비밀번호를 입력해주세요.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSecondary,
                ),
              ),
              ResponsiveSizedBox(height: 20),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '8자 이상 영문,숫자,특수문자 포함',
                  labelStyle: theme.textTheme.bodyMedium,
                  border: const OutlineInputBorder(),
                ),
              ),
              ResponsiveSizedBox(height: 20),
              ClickButton(
                text: '확인',
                onPressed: () {
                  // 비밀번호 업데이트 로직
                  // 사용자에게 피드백 제공
                },
                // width: MediaQuery.of(context).size.width * 0.5, // 원하는 너비 설정
                // height: 50.0, // 원하는 높이 설정
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
