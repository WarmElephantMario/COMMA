import 'package:flutter/material.dart';
import 'package:flutter_plugin/components.dart';
import '../model/44_font_size_provider.dart';
import 'package:provider/provider.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 폰트 크기 비율을 Provider에서 가져옴
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    // 디스플레이 비율을 가져옴
    final scaleFactor = fontSizeProvider.scaleFactor;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 48, 48, 48)),
        title: const Text(
          '도움말',
          style: TextStyle(
              color: Color.fromARGB(255, 48, 48, 48),
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w600),
        ),
      ),
      body: const Center(
        child: Text('도움말 페이지 내용'),
      ),
      bottomNavigationBar:
          buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}
