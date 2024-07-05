import 'package:flutter/material.dart';

class HomePageNoRecent extends StatelessWidget {
  const HomePageNoRecent({super.key});

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: SizedBox(
          height: 45,
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color.fromRGBO(228, 240, 231, 100),
              hintText: '검색할 파일명을 입력하세요.',
              hintStyle: const TextStyle(
                color: Color(0xFF36AE92),
                fontSize: 15,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF36AE92),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
            ),
          ),
        ),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(50.0),
          child: Column(
            children: [
              Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        '검색 결과가 없어요.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                      Text(
                        '다른 키워드로 다시 검색해 보세요.',
                        style: TextStyle(
                          color: Color(0xFF575757),
                          fontSize: 13,
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: Scaffold(
      body: HomePageNoRecent(),
    ),
  ));
}
