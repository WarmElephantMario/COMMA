import 'package:flutter/material.dart';

class HomePageNoRecent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          height: 45,
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Color.fromRGBO(228, 240, 231, 100),
              hintText: '검색할 파일명을 입력하세요.',
              hintStyle: TextStyle(
                color: Color(0xFF36AE92),
                fontSize: 15,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Color(0xFF36AE92),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10.0),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  '최근 검색 내역이 없어요.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: HomePageNoRecent(),
    ),
  ));
}