import 'package:flutter/material.dart';
import '61popup_prepare.dart'; // Import the dialog file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '오늘의 학습 준비하기',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: LearningPreparation(),
    );
  }
}

class LearningPreparation extends StatefulWidget {
  @override
  _LearningPreparationState createState() => _LearningPreparationState();
}

class _LearningPreparationState extends State<LearningPreparation> {
  int _selectedOption = 0;
  int _currentIndex = 2; // 학습 시작 탭이 기본 선택되도록 설정
  bool _isMaterialEmbedded = false; // 강의 자료가 임베드되었는지 여부를 관리하는 변수
  bool _isIconVisible = true; // 아이콘이 보이는지 여부를 관리하는 변수

  void _showLearningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LearningDialog(this.context); // Pass the parent context
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // Hide the AppBar
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Text(
              '오늘의 학습 준비하기',
              style: TextStyle(
                color: Color(0xFF414141),
                fontSize: 24,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              '학습 유형을 선택해주세요.',
              style: TextStyle(
                color: Color(0xFF575757),
                fontSize: 16,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Radio(
                  value: 0,
                  groupValue: _selectedOption,
                  onChanged: (value) {
                    setState(() {
                      _selectedOption = value!;
                    });
                  },
                  activeColor: Color(0xFF36AE92),
                ),
                const SizedBox(width: 8),
                Text(
                  '대체텍스트 생성',
                  style: TextStyle(
                    color: Color(0xFF414141),
                    fontSize: 16,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Radio(
                  value: 1,
                  groupValue: _selectedOption,
                  onChanged: (value) {
                    setState(() {
                      _selectedOption = value!;
                    });
                  },
                  activeColor: Color(0xFF36AE92),
                ),
                const SizedBox(width: 8),
                Text(
                  '실시간 자막 생성',
                  style: TextStyle(
                    color: Color(0xFF414141),
                    fontSize: 16,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    if (_isMaterialEmbedded) {
                      _showLearningDialog(); // 버튼 클릭 시 팝업 창 표시
                    } else {
                      _isMaterialEmbedded = true; // 버튼 클릭 시 상태 업데이트
                      _isIconVisible = false; // 아이콘 숨기기
                    }
                  });
                },
                icon: _isIconVisible
                    ? ImageIcon(
<<<<<<< HEAD
                  AssetImage('/Users/bag-yena/StudioProjects/comma_script/lib/assets/Vector.png'),
=======
                  AssetImage('assets/navigation_bar/home.png'),
>>>>>>> 80dd8e0076664cb755496179f9460b252c3bc1c3
                  color: Colors.white,
                )
                    : Container(), // 아이콘이 보이지 않도록 빈 컨테이너 사용
                label: Text(
                  _isMaterialEmbedded ? '강의 자료 학습 시작하기' : '강의 자료를 임베드하세요',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0XFF36AE92),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            if (_isMaterialEmbedded) ...[
              const SizedBox(height: 20),
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
                          style: TextStyle(
                            color: Color(0xFF575757),
                            fontSize: 15,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          '2024년 6월 11일  845kb',
                          style: TextStyle(
                            color: Color(0xFF575757),
                            fontSize: 14,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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
<<<<<<< HEAD
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
=======
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
>>>>>>> 80dd8e0076664cb755496179f9460b252c3bc1c3
            label: '마이페이지',
          ),
        ],
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.black,
        selectedIconTheme: IconThemeData(color: Colors.teal),
        unselectedIconTheme: IconThemeData(color: Colors.black),
        selectedLabelStyle: TextStyle(
          color: Colors.teal,
          fontSize: 9,
          fontFamily: 'DM Sans',
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          color: Colors.black,
          fontSize: 9,
          fontFamily: 'DM Sans',
          fontWeight: FontWeight.bold,
        ),
        showUnselectedLabels: true,
      ),
    );
  }
}
