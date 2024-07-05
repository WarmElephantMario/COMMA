// import 'package:flutter/material.dart';
// import '32_home_screen.dart';
// import '30_folder_screen.dart';
// import '33_mypage_screen.dart';
// import '60prepare.dart';
// import '10_homepage_no_recent.dart';
//
// void main() => runApp(const MyApp());
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const MyHomePage(),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _selectedIndex = 0;
//
//   static final List<Widget> _widgetOptions = <Widget>[
//     HomePageNoRecent(),
//     FolderScreen(),
//     LearningPreparation(), // const 키워드를 제거
//     MyPageScreen(),
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '1_Splash_green.dart';
import '5_Signup.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromRGBO(54, 174, 146, 1.0),
      ),
      home: Scaffold(
        body: SplashScreen(),
      ),
    );
  }
}
