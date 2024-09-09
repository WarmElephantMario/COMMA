import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_plugin/16_homepage_move.dart';
import 'package:flutter_plugin/2_onboarding-1.dart';
import 'package:path_provider/path_provider.dart'; // path_provider 임포트
import 'dart:io'; // Directory 사용을 위해 추가
import 'components.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import '1_Splash_green.dart'; // SplashScreen import
import 'model/user_provider.dart'; // UserProvider import
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences for userKey

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [MyNavigatorObserver()],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(), // 앱 시작 시 SplashScreen으로 이동
    );
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userKey = prefs.getString('userKey');

    if (userKey != null) {
      // userKey가 존재하면 MainPage로 이동
      Provider.of<UserProvider>(context, listen: false).setUserID(userKey);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } else {
      // userKey가 없으면 OnboardingScreen으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // userKey 확인 중 로딩 표시
      ),
    );
  }
}

class MyNavigatorObserver extends NavigatorObserver {
  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute == null) {
      // 뒤로 가기로 앱 종료 또는 초기화 시 로그아웃 로직 추가
      print('뒤로가기로 앱 종료 또는 초기화');
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String? _tempDirPath;

  @override
  void initState() {
    super.initState();
    _initTempDir();
  }

  Future<void> _initTempDir() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      setState(() {
        _tempDirPath = tempDir.path;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) {
          return true;
        } else {
          // 앱을 종료하지 않고 로그인 상태를 유지합니다.
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Path Provider Example'),
        ),
        body: Center(
          child: Text('Temporary Directory: $_tempDirPath'),
        ),
        bottomNavigationBar:
            buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
      ),
    );
  }
}
