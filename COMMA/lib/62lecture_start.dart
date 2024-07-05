import 'package:flutter/material.dart';
import 'components.dart';
import '63record.dart'; 
import '30_folder_screen.dart';
import '33_mypage_screen.dart';
import '60prepare.dart';
import '10_homepage_no_recent.dart';

class LectureStartPage extends StatefulWidget {
  @override
  _LectureStartPageState createState() => _LectureStartPageState();
}

class _LectureStartPageState extends State<LectureStartPage> {
  int _currentIndex = 2; 

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

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
            SizedBox(height: 15),
            GestureDetector(
              onTap: () {
                showQuickMenu(context);
              },
              child: Row(
                children: [
                  Image.asset('assets/folder_search.png'),
                  SizedBox(width: 8),
                  Text(
                    '폴더 분류 > 기본 폴더',
                    style: TextStyle(
                      color: Color(0xFF575757),
                      fontSize: 12,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Image.asset('assets/text.png'),
                SizedBox(width: 8),
                Text(
                  '새로운 노트',
                  style: TextStyle(
                    color: Color(0xFF575757),
                    fontSize: 12,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
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
      bottomNavigationBar: buildBottomNavigationBar(context, _currentIndex, _onItemTapped),
    );
  }
}

class Checkbox1 extends StatefulWidget {
  final String label;

  Checkbox1({required this.label});

  @override
  _Checkbox1State createState() => _Checkbox1State();
}

class _Checkbox1State extends State<Checkbox1> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          width: size.width,
          height: 24,
          padding: EdgeInsets.only(left: 18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isChecked = !isChecked;
                  });
                  print('checkbox is clicked');
                },
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isChecked ? Color(0xFF36AE92) : Colors.grey, width: 2),

                  ),
                ),
              ),
              SizedBox(width: 8), // Add some spacing between the checkbox and the text
              Text(
                widget.label,
                style: TextStyle(
                  color: Color(0xFF1F1F39),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
