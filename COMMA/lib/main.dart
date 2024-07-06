import 'package:flutter/material.dart';
import 'package:flutter_plugin/11_homepage_recent.dart';
import 'package:flutter_plugin/16_homepage_move.dart';
import 'components.dart';
import 'model/user.dart';




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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MainPage(userInfo : User(1, 'example@example.com', '010-1234-5678', 'password123')), // 초기 시작 화면
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '1_Splash_green.dart';
// import '5_Signup.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const FigmaToCodeApp());
// }

// class FigmaToCodeApp extends StatelessWidget {
//   const FigmaToCodeApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       theme: ThemeData.dark().copyWith(
//         scaffoldBackgroundColor: const Color.fromRGBO(54, 174, 146, 1.0),
//       ),
//       home: Scaffold(
//         body: SplashScreen(),
//       ),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _selectedIndex = 0;

//   static final List<Widget> _widgetOptions = <Widget>[
//     HomePageNoRecent(),
//     FolderScreen(),
//     LearningPreparation(),
//     MyPageScreen(),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: _widgetOptions.elementAt(_selectedIndex),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: [
//           BottomNavigationBarItem(
//             icon: ImageIcon(AssetImage('assets/navigation_bar/home.png')),
//             label: 'HOME',
//           ),
//           BottomNavigationBarItem(
//             icon: ImageIcon(AssetImage('assets/navigation_bar/folder.png')),
//             label: '폴더',
//           ),
//           BottomNavigationBarItem(
//             icon: ImageIcon(AssetImage('assets/navigation_bar/learningstart.png')),
//             label: '학습 시작',
//           ),
//           BottomNavigationBarItem(
//             icon: ImageIcon(AssetImage('assets/navigation_bar/mypage.png')),
//             label: '마이페이지',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.teal,
//         unselectedItemColor: Colors.black,
//         selectedIconTheme: IconThemeData(color: Colors.teal),
//         unselectedIconTheme: IconThemeData(color: Colors.black),
//         selectedLabelStyle: TextStyle(
//           color: Colors.teal,
//           fontSize: 9,
//           fontFamily: 'DM Sans',
//           fontWeight: FontWeight.bold,
//         ),
//         unselectedLabelStyle: TextStyle(
//           color: Colors.black,
//           fontSize: 9,
//           fontFamily: 'DM Sans',
//           fontWeight: FontWeight.bold,
//         ),
//         showUnselectedLabels: true,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }

