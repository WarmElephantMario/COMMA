import 'package:flutter/material.dart';
import 'package:flutter_plugin/components.dart';

class HelpPage extends StatefulWidget {
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color.fromARGB(255, 48, 48, 48)),
        title: Text(
          '도움말',
        style: TextStyle(
          color: Color.fromARGB(255, 48, 48, 48),
          fontFamily: 'DM Sans',
          fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: Text('도움말 페이지 내용'),
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}
