import 'package:flutter/material.dart';
import 'package:flutter_plugin/11_homepage_recent.dart';
import 'package:flutter_plugin/16_homepage_move.dart';
import 'components.dart';
import 'model/user.dart';
import '30_folder_screen.dart';
import '33_mypage_screen.dart';
import '60prepare.dart';
import '10_homepage_no_recent.dart';
import '1_Splash_green.dart';
import '5_Signup.dart';

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
      home: SplashScreen(),
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
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

