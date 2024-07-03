import 'package:flutter/material.dart';
import '60prepare.dart';

class ColonPage extends StatefulWidget {
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
                      MaterialPageRoute(builder: (context) => LearningPreparation()),
                    );
                  },
                  child: Text(
                    '종료',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                ImageIcon(AssetImage('assets/folder_search.png')),
                const SizedBox(width: 8),
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
            Text(
              '새로운 노트',
              style: TextStyle(
                color: Color(0xFF414141),
                fontSize: 20,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '강의 자료: Ch01. What is Algorithm?',
              style: TextStyle(
                color: Color(0xFF575757),
                fontSize: 12,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 5), // 추가된 날짜와 시간을 위한 공간
            Text(
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
                ElevatedButton(
                  onPressed: () {

                  },
                  child: Text(
                    '콜론(:) 다운하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0XFF36AE92),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '네 여러분 안녕하세요\n그래서 지난번에 공부한 Time Complexity 관련된 공식을 모두 공부해 오셨겠지요?\n다시 한 번 설명하지만 알고리즘에 있어서 Time complexity는 개발자라면 꼭 필수적으로 고려할 줄 알아야 하는 문제라고 했었음',
              style: TextStyle(
                color: Color(0xFF414141),
                fontSize: 16,
                fontFamily: 'DM Sans',
              ),
            ),
            Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/navigation_bar/home.png')),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/navigation_bar/folder.png')),
            label: '폴더',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/navigation_bar/learningstart.png')),
            label: '학습 시작',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/navigation_bar/mypage.png')),
            label: '마이페이지',
          ),
        ],
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.black,
        selectedIconTheme: IconThemeData(color: Colors.teal),
        unselectedIconTheme: IconThemeData(color: Colors.black),
        selectedLabelStyle: TextStyle(
          color: Colors.teal,
          fontSize: 9, // 글씨 크기 설정
          fontFamily: 'DM Sans', // 글씨체 설정
          fontWeight: FontWeight.bold,
        ), // 글씨 두께 설정),
        unselectedLabelStyle: TextStyle(
          color: Colors.black,
          fontSize: 9, // 글씨 크기 설정
          fontFamily: 'DM Sans', // 글씨체 설정
          fontWeight: FontWeight.bold,
        ),
        showUnselectedLabels: true, // 모든 텍스트 라벨을 항상 표시하도록 설정
      ),
    );
  }
}
