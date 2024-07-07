import 'package:flutter/material.dart';
import '60prepare.dart';
import 'components.dart'; // ClickButton 임포트

class ColonPage extends StatefulWidget {
  const ColonPage({super.key});

  @override
  _ColonPageState createState() => _ColonPageState();
}

class _ColonPageState extends State<ColonPage> {
  int _currentIndex = 2; // 학습 시작 탭이 기본 선택되도록 설정

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // Hide the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LearningPreparation()),
                    );
                  },
                  child: const Text(
                    '종료',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const Row(
              children: [
                ImageIcon(AssetImage('assets/folder_search.png')),
                SizedBox(width: 8),
                Text(
                  '폴더 분류 > 기본 폴더',
                  style: TextStyle(
                    color: Color(0xFF575757),
                    fontSize: 12,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            const Text(
              '새로운 노트',
              style: TextStyle(
                color: Color(0xFF414141),
                fontSize: 20,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              '강의 자료: Ch01. What is Algorithm?',
              style: TextStyle(
                color: Color(0xFF575757),
                fontSize: 12,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 5), // 추가된 날짜와 시간을 위한 공간
            const Text(
              '2024/06/07 오후 2:30',
              style: TextStyle(
                color: Color(0xFF575757),
                fontSize: 12,
                fontFamily: 'DM Sans',
              ),
            ),

            const SizedBox(height: 20), // 강의 자료 밑에 여유 공간 추가
            Row(
              children: [
                ClickButton(
                  text: '콜론(:) 다운하기',
                  onPressed: () {},
                  width: MediaQuery.of(context).size.width * 0.3, // 원하는 너비 설정
                  height: 40.0, // 원하는 높이 설정
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              '네 여러분 안녕하세요\n그래서 지난번에 공부한 Time Complexity 관련된 공식을 모두 공부해 오셨겠지요?\n다시 한 번 설명하지만 알고리즘에 있어서 Time complexity는 개발자라면 꼭 필수적으로 고려할 줄 알아야 하는 문제라고 했었음',
              style: TextStyle(
                color: Color(0xFF414141),
                fontSize: 16,
                fontFamily: 'DM Sans',
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
