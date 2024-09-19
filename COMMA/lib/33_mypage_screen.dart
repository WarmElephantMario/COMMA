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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

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
            (Route<dynamic> route) => false);
      } else {
        Fluttertoast.showToast(msg: '회원 탈퇴 중 오류가 발생했습니다.');
      }
    } else {
      Fluttertoast.showToast(msg: '서버 오류: 회원 탈퇴 실패');
    }
  }

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

  @override
  Widget build(BuildContext context) {
    // 폰트 크기 비율을 Provider에서 가져옴
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    // 디스플레이 비율을 가져옴
    final scaleFactor = fontSizeProvider.scaleFactor;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    int disType = userProvider.user?.dis_type ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Focus(
          focusNode: _appBarFocusNode,
          child: const Text(
            '마이페이지',
            style: TextStyle(
                color: Color.fromARGB(255, 48, 48, 48),
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700),
          ),
        ),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 48, 48, 48)),
      ),
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
          _buildCard(context, '글씨 크기 조정', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const FontSizePage()));
          }),
        SizedBox(height: 50), 

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                '학습 모드를 변경하시려면 스위치를 당겨 재부팅하세요',
                textAlign: TextAlign.center, // 중앙 정렬
                style: TextStyle(
                    fontSize: 16.0 *scaleFactor, color: Colors.grey[600]), // 글씨 크기 수정
              ),
            ),
          ),

            // 스위치와 설명 텍스트 추가
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // 중앙에 위치하도록 설정
            children: [
              // 스위치 왼쪽 설명: 시각장애인 모드
              Expanded(
              child:Padding(
                padding: const EdgeInsets.only(right: 8.0), // 간격 추가
                child: Text(
                  '시각장애인 모드', // 스위치 왼쪽 텍스트
                  style: TextStyle(fontSize: 16.0*scaleFactor), // 글씨 크기 키움
                  overflow: TextOverflow.ellipsis, // 텍스트가 너무 길 경우 생략 부호 표시
                ),
                
              ),
              ),
              SizedBox(width: 15,), 

              // 스위치 위젯
              Transform.scale(
                scale: 1.5, // 스위치 크기
                child: Switch(
                  value: disType == 1, // If disType is 1, the switch is on
                  onChanged: (bool newValue) async {
                    // Update the dis_type value and call the backend
                    int updatedDisType = newValue ? 1 : 0;
                    await _updateDisType(updatedDisType); // Update in the database

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
                  inactiveThumbColor: Colors.white, // 스위치 꺼진 상태의 thumb(단추) 색상 (흰색)
                ),
              ),

              SizedBox(width: 15,), 
              // 스위치 오른쪽 설명: 청각장애인 모드
              Expanded(
              child : Padding(
                padding: const EdgeInsets.only(left: 8.0), // 간격 추가
                child: Text(
                  '청각장애인 모드', // 스위치 오른쪽 텍스트
                  style: TextStyle(fontSize: 16.0*scaleFactor),
                  overflow: TextOverflow.ellipsis, // 텍스트가 너무 길 경우 생략 부호 표시 // 글씨 크기 키움
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
