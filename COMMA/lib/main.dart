import 'package:flutter/material.dart';
import '30_folder_screen.dart';
import '33_mypage_screen.dart';
import '60prepare.dart';
import '10_homepage_no_recent.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePageNoRecent(),
    const FolderScreen(),
    LearningPreparation(), // const 키워드를 제거
    const MyPageScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/navigation_bar/home.png')),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/navigation_bar/folder.png')),
            label: '폴더',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
                AssetImage('assets/navigation_bar/learningstart.png')),
            label: '학습 시작',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/navigation_bar/mypage.png')),
            label: '마이페이지',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.black,
        selectedIconTheme: const IconThemeData(color: Colors.teal),
        unselectedIconTheme: const IconThemeData(color: Colors.black),
        selectedLabelStyle: const TextStyle(
          color: Colors.teal,
          fontSize: 9,
          fontFamily: 'DM Sans',
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          color: Colors.black,
          fontSize: 9,
          fontFamily: 'DM Sans',
          fontWeight: FontWeight.bold,
        ),
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
