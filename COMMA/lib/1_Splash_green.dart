// splash_screen.dart
import 'package:flutter/material.dart';
import '2_onboarding-1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '16_homepage_move.dart';
import 'model/user_provider.dart';
import 'model/user.dart';

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
    print('유저키 확인');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId != null) {
      print('유저아이디 존재함 --> mainpage로 이동');
      print('유저아이디 : $userId');

      // userKey가 존재하면 MainPage로 이동
      // 로컬 저장소에서 userKey와 user_nickname 불러오기
      int? userKey = prefs.getInt('user_key');
      String? userNickname = prefs.getString('user_nickname');
      int? disType = prefs.getInt('dis_type');

      print('유저키 : $userKey // 유저타입 : $disType');

      if (userKey != null && userNickname != null) {
        // UserProvider에 설정
        Provider.of<UserProvider>(context, listen: false)
            .setUser(User(userKey, userId!, userNickname, disType));
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } else {
      print('유저키 없음');
      // userKey가 없으면 OnboardingScreen으로 이동
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
