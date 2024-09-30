import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components.dart';
import 'mypage/42_help_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'model/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'api/api.dart';
import '1_Splash_green.dart';
import 'mypage/44_font_size_page.dart';
import 'mypage/43_accessibility_settings.dart';
import 'mypage/43_accessibility_settings.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  int _selectedIndex = 3;
  final FocusNode _appBarFocusNode = FocusNode();

  String nickname = "-";

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    nickname = userProvider.user?.user_nickname ?? "-";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appBarFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _appBarFocusNode.dispose();
    super.dispose();
  }

  Widget _buildCard(BuildContext context, String title, VoidCallback onTap) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          // border: Border.all(color: Colors.grey[600]!, width: 2),
          borderRadius: BorderRadius.circular(10),
          boxShadow: theme.brightness == Brightness.light
              ? [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4), // Shadow color
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // Shadow position
                  ),
                ]
              : [], // No shadow in dark mode
        ),
        child: ListTile(
          title: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onTertiary,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: theme.colorScheme.onSecondary,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Future<void> deleteUser(BuildContext context) async {
    // ... 기존 deleteUser 코드 ...
  }

  Future<void> _updateDisType(int updatedDisType) async {
    // ... 기존 _updateDisType 코드 ...
  }

  Future<void> _updateNickname(String newNickname) async {
    // ... 기존 _updateNickname 코드 ...
  }

  void _showEditNameDialog() {
    final TextEditingController nicknameController =
        TextEditingController(text: nickname);

    final FocusNode titleFocusNode = FocusNode();
    final FocusNode contentFocusNode = FocusNode();
    final FocusNode cancelFocusNode = FocusNode();
    final FocusNode saveFocusNode = FocusNode();

    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Semantics(
            sortKey: const OrdinalSortKey(1.0),
            child: Text(
              '닉네임 변경하기',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onTertiary,
              ),
            ),
          ),
          content: Semantics(
            sortKey: const OrdinalSortKey(2.0),
            child: TextField(
              focusNode: contentFocusNode,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondary,
              ),
              controller: nicknameController,
              decoration: InputDecoration(
                hintText: '새 닉네임을 입력하세요',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSecondary,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: theme.colorScheme.onSecondary,
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: theme.colorScheme.onSecondary,
                  ),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            Semantics(
              sortKey: const OrdinalSortKey(3.0),
              child: TextButton(
                focusNode: cancelFocusNode,
                child: Text(
                  '취소',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Semantics(
              sortKey: const OrdinalSortKey(4.0),
              child: TextButton(
                focusNode: saveFocusNode,
                child: Text(
                  '저장',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                onPressed: () async {
                  String newNickname = nicknameController.text;
                  await _updateNickname(newNickname);
                  setState(() {
                    nickname = newNickname;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(titleFocusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    int disType = userProvider.user?.dis_type ?? 0;

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Focus(
          focusNode: _appBarFocusNode,
          child: Text(
            '마이페이지',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onSecondary),
      ),
      body: ListView(
        children: <Widget>[
          ResponsiveSizedBox(height: 15),
          _buildCard(context, '닉네임 변경하기', () {
            _showEditNameDialog();
          }),
          _buildCard(context, '화면 모드', () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AccessibilitySettings()));
          }),
          _buildCard(context, '글씨 크기 조정', () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FontSizePage()));
          }),
          _buildCard(context, '도움말', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HelpPage()));
          }),
          _buildCard(context, '회원탈퇴', () {
            showConfirmationDialog(
              context,
              '회원탈퇴',
              '정말 탈퇴하시겠습니까? \n삭제된 모든 자료는 복구되지 않습니다.',
              () async {
                await deleteUser(context);
              },
            );
          }),
          ResponsiveSizedBox(height: 50),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                '학습 모드를 변경하시려면 스위치를 당겨 재부팅하세요',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSecondary,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: MediaQuery.of(context).size.width * 0.075),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '시각장애인 모드',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onTertiary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.0375),
              Transform.scale(
                scale: 1.5,
                child: Switch(
                  value: disType == 1,
                  onChanged: (bool newValue) async {
                    int updatedDisType = newValue ? 1 : 0;
                    await _updateDisType(updatedDisType);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SplashScreen()),
                    );
                  },
                  activeTrackColor: Colors.teal,
                  activeColor: Colors.white,
                  inactiveTrackColor: Colors.teal,
                  inactiveThumbColor: Colors.white,
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.0375),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '청각장애인 모드',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onTertiary,
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
      bottomNavigationBar:
          buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}
