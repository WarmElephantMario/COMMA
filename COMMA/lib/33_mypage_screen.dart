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
import 'mypage/43_font_size_page.dart';
import '../model/44_font_size_provider.dart';

// MyPageScreen 클래스 정의
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
    // 폰트 크기 비율을 Provider에서 가져옴
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    // 디스플레이 비율을 가져옴
    final scaleFactor = fontSizeProvider.scaleFactor;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          border: Border.all(color: Colors.grey[600]!, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          title: Text(title),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: theme.colorScheme.onSecondary,
          ),
          onTap: onTap,
          textColor: theme.colorScheme.onTertiary,
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

        //userProvider에서 userKey 기록 삭제 (user 기록 전체 비우기)
        Provider.of<UserProvider>(context, listen: false).logOut();

        // SharedPreferences에서 userKey 삭제
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('userKey');

        // SplashGreenScreen 화면으로 이동
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SplashScreen()),
            (Route<dynamic> route) => false);
      } else {
        Fluttertoast.showToast(msg: '회원 탈퇴 중 오류가 발생했습니다.');
      }
    } else {
      Fluttertoast.showToast(msg: '서버 오류: 회원 탈퇴 실패');
    }
  }

  //스위치 당겨서 학습 모드 (dis_type) 변경하기
  Future<void> _updateDisType(int updatedDisType) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userKey = userProvider.user?.userKey ?? 0;

    final response = await http.put(
      Uri.parse('${API.baseUrl}/api/update_dis_type'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userKey': userKey,
        'dis_type': updatedDisType,
      }),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
        userProvider.updateDisType(updatedDisType); // Update in the provider
        Fluttertoast.showToast(msg: '학습 모드가 성공적으로 업데이트되었습니다.');
      } else {
        Fluttertoast.showToast(msg: '학습 모드 업데이트 중 오류가 발생했습니다.');
      }
    } else {
      Fluttertoast.showToast(msg: '서버 오류: 학습 모드 업데이트 실패');
    }
  }

  //닉네임 업데이트 함수
  Future<void> _updateNickname(String newNickname) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userKey = userProvider.user?.userKey ?? 0;

    final response = await http.put(
      Uri.parse('${API.baseUrl}/api/update_nickname'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userKey': userKey,
        'user_nickname': newNickname,
      }),
    );

    print('Request body: ${jsonEncode({
          'userKey': userKey,
          'user_nickname': newNickname,
        })}');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
        userProvider.updateUserNickname(newNickname);
        Fluttertoast.showToast(msg: '닉네임이 성공적으로 업데이트되었습니다.');
      } else {
        Fluttertoast.showToast(msg: '닉네임 업데이트 중 오류가 발생했습니다.');
      }
    } else {
      Fluttertoast.showToast(msg: '서버 오류: 닉네임 업데이트 실패');
    }
  }

  //닉네임 수정 dialog 팝업창
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
            sortKey: OrdinalSortKey(1.0),
            child: Focus(
              focusNode: titleFocusNode,
              child: Text(
                '닉네임 변경하기',
                style: TextStyle(color: theme.colorScheme.onTertiary),
              ),
            ),
          ),
          content: Semantics(
            sortKey: OrdinalSortKey(2.0),
            child: Focus(
              focusNode: contentFocusNode,
              child: TextField(
                style: TextStyle(color: theme.colorScheme.onSecondary),
                controller: nicknameController,
                decoration: InputDecoration(
                    hintText: '새 닉네임을 입력하세요',
                    hintStyle: TextStyle(color: theme.colorScheme.onSecondary)),
              ),
            ),
          ),
          actions: <Widget>[
            Semantics(
              sortKey: OrdinalSortKey(3.0),
              child: Focus(
                focusNode: cancelFocusNode,
                child: TextButton(
                  child: Text('취소',
                      style: TextStyle(
                          color: theme.colorScheme.tertiary, fontSize: 15)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            Semantics(
              sortKey: OrdinalSortKey(4.0),
              child: Focus(
                focusNode: saveFocusNode,
                child: TextButton(
                  child: Text(
                    '저장',
                    style: TextStyle(
                        color: theme.colorScheme.primary, fontSize: 15),
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
    // 폰트 크기 비율을 Provider에서 가져옴
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    // 디스플레이 비율을 가져옴
    final scaleFactor = fontSizeProvider.scaleFactor;
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
            style: TextStyle(
                color: theme.colorScheme.onSecondary,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700),
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onSecondary),
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 15),
          _buildCard(context, '닉네임 변경하기', () {
            _showEditNameDialog();
          }),
           _buildCard(context, '글씨 크기 조정', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const FontSizePage()));
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
          SizedBox(height: 50),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                '학습 모드를 변경하시려면 스위치를 당겨 재부팅하세요',
                textAlign: TextAlign.center, // 중앙 정렬
                style: TextStyle(
                    fontSize: 16.0 * scaleFactor,
                    color: theme.colorScheme.onSecondary), // 글씨 크기 수정
              ),
            ),
          ),

          // 스위치와 설명 텍스트 추가
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // 중앙에 위치하도록 설정
            children: [
              // 스위치 왼쪽 설명: 시각장애인 모드
              SizedBox(width: 30 * scaleFactor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0), // 간격 추가
                  child: Text(
                    '시각장애인 모드', // 스위치 왼쪽 텍스트
                    style: TextStyle(
                        fontSize: 16.0 * scaleFactor,
                        color: theme.colorScheme.onTertiary), // 글씨 크기 키움
                  ),
                ),
              ),
              SizedBox(width: 15 * scaleFactor),

              // 스위치 위젯
              Transform.scale(
                scale: 1.5, // 스위치 크기
                child: Switch(
                  value: disType == 1, // If disType is 1, the switch is on
                  onChanged: (bool newValue) async {
                    // Update the dis_type value and call the backend
                    int updatedDisType = newValue ? 1 : 0;
                    await _updateDisType(
                        updatedDisType); // Update in the database

                    // After updating, restart the app by navigating to SplashScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SplashScreen()), // Navigate to splash screen
                    );
                  },
                  activeTrackColor: Colors.teal, // 스위치 켜진 상태의 트랙 색상 (초록색)
                  activeColor: Colors.white, // 스위치 켜진 상태의 thumb(단추) 색상 (흰색)
                  inactiveTrackColor: Colors.teal, // 스위치 꺼진 상태의 트랙 색상 (초록색)
                  inactiveThumbColor:
                      Colors.white, // 스위치 꺼진 상태의 thumb(단추) 색상 (흰색)
                ),
              ),

              SizedBox(width: 15 * scaleFactor),
              // 스위치 오른쪽 설명: 청각장애인 모드
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0), // 간격 추가
                  child: Text(
                    '청각장애인 모드', // 스위치 오른쪽 텍스트
                    style: TextStyle(
                        fontSize: 16.0 * scaleFactor,
                        color: theme.colorScheme.onTertiary),
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
