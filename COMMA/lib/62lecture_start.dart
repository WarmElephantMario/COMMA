import 'package:flutter/material.dart';
import 'components.dart';
import '63record.dart';

class LectureStartPage extends StatefulWidget {
  const LectureStartPage({super.key});

  @override
  _LectureStartPageState createState() => _LectureStartPageState();
}

class _LectureStartPageState extends State<LectureStartPage> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
            const Text(
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
            const Text(
              '업로드 한 강의 자료의 AI 학습이 완료되었어요!\n학습을 시작하려면 강의실에 입장하세요',
              style: TextStyle(
                color: Color(0xFF575757),
                fontSize: 14,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: const Row(
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
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () {
                // showQuickMenu(context);
              },
              child: Row(
                children: [
                  Image.asset('assets/folder_search.png'),
                  const SizedBox(width: 8),
                  const Text(
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
            const SizedBox(height: 10),
            Row(
              children: [
                Image.asset('assets/text.png'),
                const SizedBox(width: 8),
                const Text(
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
            const SizedBox(height: 100),
            Center(
              child: ClickButton(
                text: '강의실 입장하기',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RecordPage()),
                  );
                },
                width: MediaQuery.of(context).size.width * 0.5, // 원하는 너비 설정
                height: 50.0, // 원하는 높이 설정
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar:
          buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}
