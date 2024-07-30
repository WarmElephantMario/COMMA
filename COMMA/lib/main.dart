import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart'; // path_provider 임포트
import 'dart:io'; // Directory 사용을 위해 추가
import 'components.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import '1_Splash_green.dart';
import 'model/user_provider.dart';

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
      home: const SplashScreen(),
    );
  }
}

class MyNavigatorObserver extends NavigatorObserver {
  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute == null) {
      // 여기에 로그아웃이나 다른 동작을 정의
      print('뒤로가기로 앱 종료 또는 초기화');
      // 로그아웃 로직을 추가하거나 다른 동작을 수행합니다.
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
