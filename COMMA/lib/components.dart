import 'package:flutter/material.dart';
import '66colon.dart';
import '62lecture_start.dart';
import '30_folder_screen.dart';
import '33_mypage_screen.dart';
import '60prepare.dart';
import '10_homepage_no_recent.dart';

//내비게이션 바
BottomNavigationBar buildBottomNavigationBar(BuildContext context, int currentIndex, Function(int) onItemTapped) {
  final List<Widget> widgetOptions = <Widget>[
    HomePageNoRecent(),
    FolderScreen(),
    LearningPreparation(),
    MyPageScreen(),
  ];

  void handleItemTap(int index) {
    onItemTapped(index);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => widgetOptions[index]),
    );
  }

  return BottomNavigationBar(
    currentIndex: currentIndex,
    onTap: handleItemTap,
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
  );
}

// 녹음종료 팝업
void showStopRecordingDialog(BuildContext context, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          '정말 녹음을 종료하시겠습니까?',
          style: TextStyle(
            color: Color(0xFF545454),
            fontSize: 14,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          '녹음을 종료하면 다시 시작할 수 없습니다.',
          style: TextStyle(
            color: Color(0xFF245B3A),
            fontSize: 11,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w200,
          ),
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    '취소',
                    style: TextStyle(
                      color: Color(0xFFFFA17A),
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    onConfirm();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    '확인',
                    style: TextStyle(
                      color: Color(0xFF545454),
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

// 콜론생성& 폴더이동 팝업
void showColonCreatedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Column(
          children: [
            Text(
              '콜론이 생성되었습니다.',
              style: TextStyle(
                color: Color(0xFF545454),
                fontSize: 14,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '폴더 이름: 기본폴더(:)',
              style: TextStyle(
                color: Color(0xFF245B3A),
                fontSize: 14,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '으로 이동하시겠습니까?',
              style: TextStyle(
                color: Color(0xFF545454),
                fontSize: 14,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: <Widget>[
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    '취소',
                    style: TextStyle(
                      color: Color(0xFFFFA17A),
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ColonPage()),
                    );
                  },
                  child: Text(
                    '확인',
                    style: TextStyle(
                      color: Color(0xFF545454),
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

// 강의 자료 학습중 팝업
void showLearningDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      // Navigate to LectureStartPage after 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        Navigator.of(context).pop(); // Close the dialog
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LectureStartPage()),
        );
      });

      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                '취소',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 16,
                  fontFamily: 'DM Sans',
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '강의 자료 학습중입니다',
              style: TextStyle(
                color: Color(0xFF414141),
                fontSize: 16,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF36AE92)),
              strokeWidth: 4.0,
            ),
            SizedBox(height: 16),
            Text(
              '75%',
              style: TextStyle(
                color: Color(0xFF414141),
                fontSize: 16,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    },
  );
}

//
void showQuickMenu(BuildContext context) {
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
                    child: Checkbox1(label: '컴퓨터 알고리즘'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Checkbox1(label: '정보통신공학'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Checkbox1(label: '데이터베이스'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }