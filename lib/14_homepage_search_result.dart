import 'package:flutter/material.dart';

class SearchingScreen extends StatelessWidget {
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
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '강의 폴더',
                    style: TextStyle(
                      color: Color(0xFF575757),
                      fontSize: 13,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print('view all button is clicked');
                    },
                    child: Row(
                      children: [
                        Text(
                          '전체 보기',
                          style: TextStyle(
                            color: Color(0xFF36AE92),
                            fontSize: 12,
                            fontFamily: 'Mulish',
                            fontWeight: FontWeight.w800,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: Color(0xFF36AE92),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  print('certain lecture is clicked');
                },
                child: LectureExample(
                  lectureName: '정보통신공학',
                  date: '2024/06/07',
                ),
              ),
              GestureDetector(
                onTap: () {
                  print('certain lecture is clicked');
                },
                child: LectureExample(
                  lectureName: '컴퓨터알고리즘',
                  date: '2024/06/10',
                ),
              ),

              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '콜론 폴더',
                    style: TextStyle(
                      color: Color(0xFF575757),
                      fontSize: 13,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print('view all2 button is clicked');
                    },
                    child: Row(
                      children: [
                        Text(
                          '전체 보기',
                          style: TextStyle(
                            color: Color(0xFF36AE92),
                            fontSize: 12,
                            fontFamily: 'Mulish',
                            fontWeight: FontWeight.w800,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: Color(0xFF36AE92),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  print('certain lecture is clicked');
                },
                child: LectureExample(
                  lectureName: '정보통신공학',
                  date: '2024/06/07',
                ),
              ),
              GestureDetector(
                onTap: () {
                  print('certain lecture is clicked');
                },
                child: LectureExample(
                  lectureName: '컴퓨터알고리즘',
                  date: '2024/06/10',
                ),
              ),
              GestureDetector(
                onTap: () {
                  print('certain lecture is clicked');
                },
                child: LectureExample(
                  lectureName: '데이터베이스',
                  date: '2024/06/15',
                ),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF36AE92),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: '폴더',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow),
            label: '학습 시작',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}

class LectureExample extends StatelessWidget {
  final String lectureName;
  final String date;

  const LectureExample({
    Key? key,
    required this.lectureName,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          color: Color(0xFFE9F3ED), // Background color
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              margin: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color(0xFF005A38), // Color of the square
                borderRadius:
                BorderRadius.circular(8), // Rounded corners for the square
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      lectureName,
                      style: TextStyle(
                        color: Color(0xFF1F1F39),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    Spacer(),
                    Text(
                      date,
                      style: TextStyle(
                        color: Color(0xFF005A38),
                        fontSize: 12,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.more_vert,
                color: Color(0xFF36AE92), // Icon color
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// void main() {
//   runApp(MaterialApp(
//     home: Scaffold(
//       body: SearchingScreen(),
//     ),
//   ));
// }