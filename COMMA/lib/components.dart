import 'package:flutter/material.dart';
import '66colon.dart';
import '62lecture_start.dart';
import '30_folder_screen.dart';
import '33_mypage_screen.dart';
import '60prepare.dart';
import '10_homepage_no_recent.dart';

//NAVIGATION BAR
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

// File Move Quick Action
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


// CONFIRM ALEART 2 - record stop
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

// Colon alarm
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

// Learning - 강의 자료 학습중 팝업
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

//checkbox
class Checkbox1 extends StatefulWidget {
  final String label;
  const Checkbox1({super.key, required this.label});

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
          padding: const EdgeInsets.only(left: 18),
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
                    border: Border.all(
                        color:
                            isChecked ? const Color(0xFF36AE92) : Colors.grey,
                        width: 2),
                  ),
                ),
              ),
              const SizedBox(
                  width:
                      8), // Add some spacing between the checkbox and the text
              Text(
                widget.label,
                style: const TextStyle(
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
//AddFolder
void showAddFolderDialog(BuildContext context, String folderType) {
    final TextEditingController folderNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '새 폴더 만들기',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: TextField(
            controller: folderNameController,
            decoration: const InputDecoration(
              hintText: '폴더 이름',
              hintStyle: TextStyle(color: Color(0xFF364B45)),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소',
                  style: TextStyle(
                      color: Color(0xFFFFA17A),
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                '만들기',
                style: TextStyle(
                    color: Color(0xFF545454),
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              onPressed: () {
                //_addFolder(folderNameController.text, folderType);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

//rename
  void showRenameFolderDialog(BuildContext context, int index,
      List<Map<String, dynamic>> folderList, String folderType) {
    final TextEditingController folderNameController =
        TextEditingController(text: folderList[index]['folder_name']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '폴더 이름 바꾸기',
            style: TextStyle(
                color: Color(0xFF545454),
                fontWeight: FontWeight.w800,
                fontSize: 20),
          ),
          content: TextField(
            controller: folderNameController,
            decoration: const InputDecoration(hintText: '폴더 이름'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소',
                  style: TextStyle(
                    color: Color(0xFFFFA17A),
                    fontWeight: FontWeight.w700,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                '저장',
                style: TextStyle(
                    color: Color(0xFF545454), fontWeight: FontWeight.w700),
              ),
              onPressed: () async {
                // await _renameFolder(folderType, folderList[index]['id'],
                //     folderNameController.text);
                // setState(() {
                //   folderList[index]['folder_name'] = folderNameController.text;
                // });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

//CONFIRM ALEART 1 - 폴더삭제
  void showDeleteFolderDialog(BuildContext context, int index,
      List<Map<String, dynamic>> folderList, String folderType) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '정말 \'${folderList[index]['folder_name']}\' 을(를) 삭제하시겠습니까?',
            style: const TextStyle(
                color: Color(0xFF545454),
                fontWeight: FontWeight.w800,
                fontSize: 15),
          ),
          content: const Text(
            '폴더를 삭제하면 다시 복구할 수 없습니다.',
            style: TextStyle(
              color: Color(0xFF245B3A),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소',
                  style: TextStyle(
                      color: Color(0xFFFFA17A), fontWeight: FontWeight.w700)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                '삭제',
                style: TextStyle(
                    color: Color(0xFF545454), fontWeight: FontWeight.w700),
              ),
              onPressed: () async {
                //await _deleteFolder(folderType, folderList[index]['id']);
                // setState(() {
                //   folderList.removeAt(index);
                // });
                Navigator.of(context).pop();
                showDeletionConfirmation(context);
              },
            ),
          ],
        );
      },
    );
  }

//delete alarm
  void showDeletionConfirmation(BuildContext context) {
    final overlay = Overlay.of(context);
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 40.0,
        left: 80,
        right: 80,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                title: const Text(
                  '삭제되었습니다.',
                  style: TextStyle(
                      color: Color(0xFF545454), fontWeight: FontWeight.w800),
                ),
                trailing: TextButton(
                  child: const Text(
                    '확인',
                    style: TextStyle(
                        color: Color(0xFFFFA17A), fontWeight: FontWeight.w700),
                  ),
                  onPressed: () {
                    if (overlayEntry != null) {
                      overlayEntry.remove();
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }

//수정필요
//moved alarm 
  void showmovedConfirmation(BuildContext context) {
    final overlay = Overlay.of(context);
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 40.0,
        left: 80,
        right: 80,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                title: const Text(
                  '이동되었습니다.',
                  style: TextStyle(
                      color: Color(0xFF545454), fontWeight: FontWeight.w800),
                ),
                trailing: TextButton(
                  child: const Text(
                    '확인',
                    style: TextStyle(
                        color: Color(0xFFFFA17A), fontWeight: FontWeight.w700),
                  ),
                  onPressed: () {
                    if (overlayEntry != null) {
                      overlayEntry.remove();
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }

//hamburger
Future<void> showCustomMenu(BuildContext context, VoidCallback onRename, VoidCallback onDelete, VoidCallback onMove) async {
  final RenderBox button = context.findRenderObject() as RenderBox;
  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

  final Offset buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
  final double left = buttonPosition.dx;
  final double top = buttonPosition.dy + button.size.height;

  await showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(left, top, left + button.size.width, top),
    items: [
      const PopupMenuItem<String>(
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
      const PopupMenuItem<String>(
        value: 'move',
        child: Center(
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
        ),
      ),
      const PopupMenuItem<String>(
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
    if (value == 'delete') {
      onDelete();
    } else if (value == 'move') {
      onMove();
    } else if (value == 'rename') {
      onRename();
    }
  });
}
  