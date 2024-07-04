import 'package:flutter/material.dart';
import '14_homepage_search_result.dart';
import 'model/user.dart';

class MainPage extends StatefulWidget {
  final User userInfo;
  const MainPage({Key? key, required this.userInfo}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        iconTheme: IconThemeData(
          color: Color(0xFF36AE92),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search_rounded,
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SearchingScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '안녕하세요, ${widget.userInfo.user_email} 님',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '최근에 학습한 강의 파일이에요.',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '최근에 학습한 콜론 파일이에요.',
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
            Builder(
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    child: Icon(
                      Icons.more_vert,
                      color: Color(0xFF36AE92), // Icon color
                    ),
                    onTap: () async {
                      final RenderBox button =
                      context.findRenderObject() as RenderBox;
                      final RenderBox overlay = Overlay.of(context)
                          .context
                          .findRenderObject() as RenderBox;

                      final Offset buttonPosition =
                      button.localToGlobal(Offset.zero, ancestor: overlay);
                      final double left = buttonPosition.dx;
                      final double top = buttonPosition.dy + button.size.height;

                      await showMenu<String>(
                        context: context,
                        position: RelativeRect.fromLTRB(
                            left, top, left + button.size.width, top),
                        items: [
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Center(
                              child: Text(
                                '삭제하기',
                                style: TextStyle(
                                  color: Color.fromRGBO(255, 161, 122, 1),
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'move',
                            child: Center(
                              child: GestureDetector(
                                child: Text(
                                  '이동하기',
                                  style: TextStyle(
                                    color: Color.fromRGBO(84, 84, 84, 1),
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
                                ),
                                onTap: () {
                                  _showQuickMenu(context);
                                },
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'rename',
                            child: Center(
                              child: Text(
                                '이름 바꾸기',
                                style: TextStyle(
                                  color: Color.fromRGBO(84, 84, 84, 1),
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.white,
                      ).then((value) {
                        if (value != null) {
                          print(value);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

void _showQuickMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    backgroundColor: Colors.white,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    '취소',
                    style: TextStyle(
                      color: Color.fromRGBO(84, 84, 84, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '다음으로 이동',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Implement the move action
                  },
                  child: Text(
                    '이동',
                    style: TextStyle(
                      color: Color.fromRGBO(255, 161, 122, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2),
            Center(
              child: Text(
                '현재 위치 외 다른 폴더로 이동할 수 있어요.',
                style: TextStyle(
                  color: Color(0xFF575757),
                  fontSize: 13,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child:
                  Checkbox1(label: '컴퓨터 알고리즘'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child:
                  Checkbox1(label: '정보통신공학'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child:
                  Checkbox1(label: '데이터베이스'),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
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

// void main() {
//   runApp(MaterialApp(
//     home: Scaffold(
//       body: MainPage(),
//     ),
//   ));
// }
