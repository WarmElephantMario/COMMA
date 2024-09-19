// splash_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import '2_onboarding-1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '16_homepage_move.dart';
import 'model/user_provider.dart';
import 'model/user.dart';
import 'package:http/http.dart' as http;
import 'api/api.dart';

import 'package:http/http.dart' as http;
import 'api/api.dart';

Future<Map<String, dynamic>?> _fetchUserDetails(int userKey) async {
  try {
    final response = await http.get(Uri.parse('${API.baseUrl}/api/user-details/$userKey'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'user_nickname': data['user_nickname'],
        'dis_type': data['dis_type']
      };
    } else {
      print('Failed to load user details: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching user details: $e');
    return null;
  }
}



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserKey(); // 앱 실행 시 userKey 확인
  }

Future<void> _checkUserKey() async {
  print('user_id 확인');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('user_id');
  print('유저아이디 : $userId');

  if (userId != null) {
    print('유저아이디 존재함 (기기번호 생성된 적 있음) --> mainpage로 이동');
    

    // 로컬 저장소에서 userKey만 불러오기
    int? userKey = prefs.getInt('userKey');
    if (userKey != null) {
      print('유저키 : $userKey');

      // 유저 정보 API 호출로 닉네임과 타입 가져오기
      final userDetails = await _fetchUserDetails(userKey);
      print('여기');

      if (userDetails != null) {
        String userNickname = userDetails['user_nickname'];
        int disType = userDetails['dis_type'];
        print('${disType}');

        // UserProvider에 닉네임 설정
        Provider.of<UserProvider>(context, listen: false).setUser(User(userKey, userId!, userNickname, null));
        print('여기22');

        // UserProvider에 타입 업데이트
        Provider.of<UserProvider>(context, listen: false).updateDisType(disType);
        // print('disType 성공적으로 Provider에 들어갔는지 확인하겠습니다');
        // final userProvider = Provider.of<UserProvider>(context, listen: false);
        // final disType2 = userProvider.user?.dis_type;
        // print('${disType2}');
        

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      }
    } else {
      print('유저키 없음 (userId는 만들었는데 userKey 생성엔 실패했던 케이스)');
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    }
  } else {
      print('유저아이디 없음 (기기번호 생성된 적 없음)  --> 온보딩으로 이동');


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
  }
}


  @override
  Widget build(BuildContext context) {
    // Get the size of the screen
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xFF36AE92),
      body: Center(
        child: Semantics(
          label: '앱 로고 COMMA',
          child: Container(
            width: size.width * 0.3, // Adjust this value to change logo size
            height: size.width * 0.3, // Maintain aspect ratio
            decoration: const BoxDecoration(
              color: Color(0xFF36AE92),
              image: DecorationImage(
                image: AssetImage('assets/logo_white.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}