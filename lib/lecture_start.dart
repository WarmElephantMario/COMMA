import 'package:flutter/material.dart';
import 'record.dart'; // Import the record.dart file where RecordPage is defined

class LectureStartPage extends StatefulWidget {
  @override
  _LectureStartPageState createState() => _LectureStartPageState();
}

class _LectureStartPageState extends State<LectureStartPage> {
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
            const SizedBox(height: 15),
            Text(
              '오늘의 학습 시작하기',
              style: TextStyle(
                color: Color(0xFF414141),
                fontSize: 24,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              '업로드 한 강의 자료의 AI 학습이 완료되었어요!\n학습을 시작하려면 강의실에 입장하세요',
              style: TextStyle(
                color: Color(0xFF575757),
                fontSize: 14,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
            SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '인공지능_ch03_algorithm.pdf',
                        style: TextStyle(color: Color(0xFF575757),
                          fontSize: 15,
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w500,
                          height: 1.2,),
                      ),
                      Text(
                        '2024년 6월 11일  845kb',
                        style: TextStyle(color: Color(0xFF575757),
                          fontSize: 14,
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w500,
                          height: 1.2,),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Image.asset('/Users/bag-yena/StudioProjects/comma_script/lib/assets/folder_search.png'),
                SizedBox(width: 8),
                Text(
                  '폴더 분류 > 기본 폴더',
                  style: TextStyle(color: Color(0xFF575757),
                    fontSize: 12,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w500,
                    height: 1.2,),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Image.asset('/Users/bag-yena/StudioProjects/comma_script/lib/assets/text.png'),
                SizedBox(width: 8),
                Text(
                  '새로운 노트',
                  style: TextStyle(color: Color(0xFF575757),
                    fontSize: 12,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w500,
                    height: 1.2,),
                ),
              ],
            ),
            SizedBox(height: 100),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to RecordPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RecordPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0XFF36AE92),
                  padding: EdgeInsets.symmetric(horizontal: 70, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // 모서리 설정
                  ),
                ),
                child: Text(
                  '강의실 입장하기',
                  style: TextStyle(
                    color: Color(0XFFFFFFFF), // 글씨 색을 흰색으로 설정
                    fontSize: 14,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
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
            icon: ImageIcon(AssetImage('/Users/bag-yena/StudioProjects/comma_script/lib/assets/navigation_bar/home.png')),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('/Users/bag-yena/StudioProjects/comma_script/lib/assets/navigation_bar/folder.png')),
            label: '폴더',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('/Users/bag-yena/StudioProjects/comma_script/lib/assets/navigation_bar/learningstart.png')),
            label: '학습 시작',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('/Users/bag-yena/StudioProjects/comma_script/lib/assets/navigation_bar/mypage.png')),
            label: '마이페이지',
          ),
        ],
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.black,
        selectedIconTheme: IconThemeData(color: Colors.teal),
        unselectedIconTheme: IconThemeData(color: Colors.black),
        selectedLabelStyle: TextStyle(color: Colors.teal,
          fontSize: 9, // 글씨 크기 설정
          fontFamily: 'DM Sans', // 글씨체 설정
          fontWeight: FontWeight.bold,
        ), // 글씨 두께 설정),
        unselectedLabelStyle: TextStyle(color: Colors.black,
          fontSize: 9, // 글씨 크기 설정
          fontFamily: 'DM Sans', // 글씨체 설정
          fontWeight: FontWeight.bold,
        ),
        showUnselectedLabels: true, // 모든 텍스트 라벨을 항상 표시하도록 설정
      ),
    );
  }
}
