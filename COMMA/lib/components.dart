import 'package:flutter/material.dart';
import 'package:flutter_plugin/16_homepage_move.dart';
import '66colon.dart';
import '62lecture_start.dart';
import '30_folder_screen.dart';
import '33_mypage_screen.dart';
import '60prepare.dart';
import 'model/user.dart';
import '11_homepage_recent.dart';

//NAVIGATION BAR
BottomNavigationBar buildBottomNavigationBar(
    BuildContext context, int currentIndex, Function(int) onItemTapped) {
  final List<Widget> widgetOptions = <Widget>[
    // MainPage(userInfo: userInfo),
    MainPage(
        userInfo:
            User(1, 'example@example.com', '010-1234-5678', 'password123')),
    const FolderScreen(),
    const LearningPreparation(),
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
    backgroundColor: Colors.white,
    onTap: handleItemTap,
    items: const [
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
    selectedIconTheme: const IconThemeData(color: Colors.teal),
    unselectedIconTheme: const IconThemeData(color: Colors.black),
    selectedLabelStyle: const TextStyle(
      color: Colors.teal,
      fontSize: 9, // 글씨 크기 설정
      fontFamily: 'DM Sans', // 글씨체 설정
      fontWeight: FontWeight.bold,
    ), // 글씨 두께 설정),
    unselectedLabelStyle: const TextStyle(
      color: Colors.black,
      fontSize: 9, // 글씨 크기 설정
      fontFamily: 'DM Sans', // 글씨체 설정
      fontWeight: FontWeight.bold,
    ),
    showUnselectedLabels: true, // 모든 텍스트 라벨을 항상 표시하도록 설정
  );
}

// File Move Quick Action
// void showQuickMenu(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(
//         top: Radius.circular(20),
//       ),
//     ),
//     backgroundColor: Colors.white,
//     builder: (BuildContext context) {
//       return Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: const Text(
//                     '취소',
//                     style: TextStyle(
//                       color: Color.fromRGBO(84, 84, 84, 1),
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 const Text(
//                   '다음으로 이동',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     // TODO: Implement the move action
//                   },
//                   child: const Text(
//                     '이동',
//                     style: TextStyle(
//                       color: Color.fromRGBO(255, 161, 122, 1),
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 2),
//             const Center(
//               child: Text(
//                 '현재 위치 외 다른 폴더로 이동할 수 있어요.',
//                 style: TextStyle(
//                   color: Color(0xFF575757),
//                   fontSize: 13,
//                   fontFamily: 'Raleway',
//                   fontWeight: FontWeight.w500,
//                   height: 1.5,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: EdgeInsets.symmetric(vertical: 5),
//                   child: Checkbox1(label: '컴퓨터 알고리즘'),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(vertical: 5),
//                   child: Checkbox1(label: '정보통신공학'),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(vertical: 5),
//                   child: Checkbox1(label: '데이터베이스'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }

// CONFIRM ALEART 1,2
void showConfirmationDialog(
  BuildContext context,
  String title,
  String content,
  VoidCallback onConfirm,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF545454),
            fontSize: 14,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          content,
          style: const TextStyle(
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
                  child: const Text(
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
                  child: const Text(
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
        title: const Column(
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
            SizedBox(height: 4),
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
            SizedBox(height: 4),
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
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      color: Color(0xFFFFA17A),
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ColonPage()),
                    );
                  },
                  child: const Text(
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
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pop(); // Close the dialog
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LectureStartPage()),
        );
      });

      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
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
        content: const Column(
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

//alarm
//delete alarm
void showDeleteAlarmDialog(BuildContext context) {
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

//moved alarm & move cancel alarm
void showAlarmDialog(BuildContext context, String message) {
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
              title: Text(
                message,
                style: const TextStyle(
                    color: Color(0xFF545454), fontWeight: FontWeight.w800),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    child: const Text(
                      '취소',
                      style: TextStyle(
                          color: Color(0xFFFFA17A),
                          fontWeight: FontWeight.w700),
                    ),
                    onPressed: () {
                      if (overlayEntry != null) {
                        overlayEntry.remove();
                      }
                    },
                  ),
                  TextButton(
                    child: const Text(
                      '확인',
                      style: TextStyle(
                          color: Color(0xFFFFA17A),
                          fontWeight: FontWeight.w700),
                    ),
                    onPressed: () {
                      if (overlayEntry != null) {
                        overlayEntry.remove();
                      }
                    },
                  ),
                ],
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
Future<void> showCustomMenu(BuildContext context, VoidCallback onRename,
    VoidCallback onDelete, VoidCallback onMove) async {
  final RenderBox button = context.findRenderObject() as RenderBox;
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;

  final Offset buttonPosition =
      button.localToGlobal(Offset.zero, ancestor: overlay);
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

//로그아웃, 회원탈퇴
void showMypageDialog(BuildContext context, String title, String message,
    VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('취소',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFFFFA17A))),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: const Text('확인',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF545454))),
          ),
        ],
      );
    },
  );
}

// 이름 바꾸기 : 폴더&파일
Future<void> showRenameDialog(
    BuildContext context,
    int index,
    List<Map<String, dynamic>> items,
    Function renameItem,
    Function setState,
    String title,
    String itemType // 'file_name' 또는 'folder_name'
    ) async {
  final TextEditingController nameController =
      TextEditingController(text: items[index][itemType]);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF545454),
            fontSize: 14,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(hintText: items[index][itemType]),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('취소', style: TextStyle(color: Color(0xFFFFA17A))),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('저장', style: TextStyle(color: Color(0xFF545454))),
            onPressed: () async {
              await renameItem(items[index]['id'], nameController.text);
              setState(() {
                items[index][itemType] = nameController.text;
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

//폴더 만들기
Future<void> showAddFolderDialog(
    BuildContext context, Function addFolder) async {
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
            onPressed: () async {
              await addFolder(folderNameController.text);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

//checkbox
// class Checkbox1 extends StatefulWidget {
//   final String label;
//   const Checkbox1({super.key, required this.label});

//   @override
//   _Checkbox1State createState() => _Checkbox1State();
// }

// class _Checkbox1State extends State<Checkbox1> {
//   bool isChecked = false;

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Column(
//       children: [
//         Container(
//           width: size.width,
//           height: 24,
//           padding: const EdgeInsets.only(left: 18),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     isChecked = !isChecked;
//                   });
//                   print('checkbox is clicked');
//                 },
//                 child: Container(
//                   width: 18,
//                   height: 18,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                         color:
//                             isChecked ? const Color(0xFF36AE92) : Colors.grey,
//                         width: 2),
//                   ),
//                 ),
//               ),
//               const SizedBox(
//                   width:
//                       8), // Add some spacing between the checkbox and the text
//               Text(
//                 widget.label,
//                 style: const TextStyle(
//                   color: Color(0xFF1F1F39),
//                   fontSize: 15,
//                   fontFamily: 'Poppins',
//                   fontWeight: FontWeight.w700,
//                   height: 1.2,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// Checkbox2 위젯
class Checkbox2 extends StatefulWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onChanged;

  const Checkbox2({
    super.key,
    required this.label,
    this.isSelected = false,
    required this.onChanged,
  });

  @override
  _Checkbox2State createState() => _Checkbox2State();
}

class _Checkbox2State extends State<Checkbox2> {
  late bool isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = widget.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
        });
        widget.onChanged(isSelected);
      },
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (value) {
              setState(() {
                isSelected = value!;
              });
              widget.onChanged(isSelected);
            },
          ),
          Text(widget.label),
        ],
      ),
    );
  }
}

// showQuickMenu 함수
void showQuickMenu(
    BuildContext context,
    int fileId,
    String fileType,
    int currentFolderId,
    Future<void> Function(int, int, String) moveItem,
    Future<void> Function() fetchOtherFolders,
    List<Map<String, dynamic>> folders,
    Function(VoidCallback) updateState) async {
  // folders 상태 초기화 및 폴더 목록 가져오기
  updateState(() {
    folders.clear();
  });

  await fetchOtherFolders();

  // 폴더 목록에 selected 속성 추가
  updateState(() {
    folders = folders.map((folder) {
      return {
        ...folder,
        'selected': false,
      };
    }).toList();
  });

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    backgroundColor: Colors.white,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
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
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          color: Color.fromRGBO(84, 84, 84, 1),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Text(
                      '다음으로 이동',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final selectedFolder = folders.firstWhere(
                            (folder) => folder['selected'] == true,
                            orElse: () => {});
                        final selectedFolderId = selectedFolder['id'];
                        await moveItem(fileId, selectedFolderId, fileType);
                        Navigator.pop(context);
                      },
                      child: const Text(
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
                const SizedBox(height: 2),
                const Center(
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
                const SizedBox(height: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: folders.map((folder) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Checkbox2(
                        label: folder['folder_name'],
                        isSelected: folder['selected'] ?? false,
                        onChanged: (bool isSelected) {
                          setState(() {
                            for (var f in folders) {
                              f['selected'] = false;
                            }
                            folder['selected'] = isSelected;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

//lecture
class LectureExample extends StatelessWidget {
  final String lectureName;
  final String date;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onMove;

  const LectureExample({
    super.key,
    required this.lectureName,
    required this.date,
    required this.onRename,
    required this.onDelete,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFFE9F3ED), // Background color
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color(0xFF005A38), // Color of the square
                borderRadius:
                    BorderRadius.circular(8), // Rounded corners for the square
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Text(
                      lectureName,
                      style: const TextStyle(
                        color: Color(0xFF1F1F39),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      date,
                      style: const TextStyle(
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
                    child: const Icon(
                      Icons.more_vert,
                      color: Color(0xFF36AE92), // Icon color
                    ),
                    onTap: () {
                      showCustomMenu(context, onRename, onDelete, onMove);
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
// class LectureExample extends StatelessWidget {
//   final String lectureName;
//   final String date;

//   const LectureExample({
//     super.key,
//     required this.lectureName,
//     required this.date,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Container(
//         width: double.infinity,
//         height: 58,
//         decoration: BoxDecoration(
//           color: const Color(0xFFE9F3ED), // Background color
//           borderRadius: BorderRadius.circular(10), // Rounded corners
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               margin: const EdgeInsets.all(8.0),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF005A38), // Color of the square
//                 borderRadius:
//                     BorderRadius.circular(8), // Rounded corners for the square
//               ),
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: Row(
//                   // crossAxisAlignment: CrossAxisAlignment.start,
//                   // mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       lectureName,
//                       style: const TextStyle(
//                         color: Color(0xFF1F1F39),
//                         fontSize: 14,
//                         fontFamily: 'Poppins',
//                         fontWeight: FontWeight.w700,
//                         height: 1.2,
//                       ),
//                     ),
//                     const Spacer(),
//                     Text(
//                       date,
//                       style: const TextStyle(
//                         color: Color(0xFF005A38),
//                         fontSize: 12,
//                         fontFamily: 'DM Sans',
//                         fontWeight: FontWeight.w500,
//                         height: 1.2,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Builder(
//               builder: (BuildContext context) {
//                 return Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: GestureDetector(
//                     child: const Icon(
//                       Icons.more_vert,
//                       color: Color(0xFF36AE92), // Icon color
//                     ),
//                     onTap: () async {
//                       final RenderBox button =
//                           context.findRenderObject() as RenderBox;
//                       final RenderBox overlay = Overlay.of(context)
//                           .context
//                           .findRenderObject() as RenderBox;

//                       final Offset buttonPosition =
//                           button.localToGlobal(Offset.zero, ancestor: overlay);
//                       final double left = buttonPosition.dx;
//                       final double top = buttonPosition.dy + button.size.height;

//                       await showMenu<String>(
//                         context: context,
//                         position: RelativeRect.fromLTRB(
//                             left, top, left + button.size.width, top),
//                         items: [
//                           const PopupMenuItem<String>(
//                             value: 'delete',
//                             child: Center(
//                               child: Text(
//                                 '삭제하기',
//                                 style: TextStyle(
//                                   color: Color.fromRGBO(255, 161, 122, 1),
//                                   fontSize: 14,
//                                   fontFamily: 'Poppins',
//                                   fontWeight: FontWeight.w700,
//                                   height: 1.2,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const PopupMenuItem<String>(
//                             value: 'move',
//                             child: Center(
//                               child: Text(
//                                 '이동하기',
//                                 style: TextStyle(
//                                   color: Color.fromRGBO(84, 84, 84, 1),
//                                   fontSize: 14,
//                                   fontFamily: 'Poppins',
//                                   fontWeight: FontWeight.w700,
//                                   height: 1.2,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const PopupMenuItem<String>(
//                             value: 'rename',
//                             child: Center(
//                               child: Text(
//                                 '이름 바꾸기',
//                                 style: TextStyle(
//                                   color: Color.fromRGBO(84, 84, 84, 1),
//                                   fontSize: 14,
//                                   fontFamily: 'Poppins',
//                                   fontWeight: FontWeight.w700,
//                                   height: 1.2,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         color: Colors.white,
//                       ).then((value) {
//                         if (value != null) {
//                           print(value);
//                         }
//                       });
//                     },
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//RenameDeletePopup 이름바꾸기
class RenameDeletePopup extends StatelessWidget {
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const RenameDeletePopup({
    super.key,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'rename') {
          onRename();
        } else if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'rename',
          child: Text('이름 바꾸기'),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('삭제하기'),
        ),
      ],
    );
  }
}

class InputButton extends StatelessWidget {
  final String label;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextEditingController controller;

  const InputButton({
    super.key,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(left: size.width * 0.05),
      width: size.width,
      height: 50,
      child: Stack(
        children: [
          Positioned(
            right: size.width * 0.05,
            left: 0,
            top: 0,
            child: Container(
              width: 335,
              height: 50,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFF9FACBD)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Positioned.fill(
            left: 20,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: label,
                    hintStyle: const TextStyle(color: Color(0xFF36AE92)),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w500,
                  ),
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  validator: (value) {
                    // Validator 추가
                    if (value == null || value.isEmpty) {
                      return '{$label} field cannot be empty';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Handle input changes if needed
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//ClickButton
class ClickButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final String? iconPath;
  final IconData? iconData;
  final Color? iconColor;
  final Color backgroundColor;

  const ClickButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 50.0,
    this.iconPath,
    this.iconData,
    this.iconColor,
    this.backgroundColor = const Color.fromRGBO(54, 174, 146, 1.0), // 기본 배경색 설정
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: width,
          height: height,
          decoration: ShapeDecoration(
            color: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconPath != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ImageIcon(
                    AssetImage(iconPath!),
                    color: Colors.white,
                  ),
                )
              else if (iconData != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    iconData,
                    color: iconColor ?? Colors.white,
                  ),
                ),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//FolderListItem
class FolderListItem extends StatelessWidget {
  final Map<String, dynamic> folder;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const FolderListItem({
    super.key,
    required this.folder,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.folder_sharp, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              folder['folder_name'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            children: [
              const Text(
                '0 files',
                style: TextStyle(
                  color: Color(0xFF005A38),
                  fontSize: 12,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(width: 10),
              RenameDeletePopup(
                onRename: onRename,
                onDelete: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
