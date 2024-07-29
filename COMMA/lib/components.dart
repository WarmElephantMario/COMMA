import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_plugin/16_homepage_move.dart';
import '66colon.dart';
import '62lecture_start.dart';
import '63record.dart';
import '30_folder_screen.dart';
import '33_mypage_screen.dart';
import '60prepare.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'model/user_provider.dart';
import 'package:provider/provider.dart';
import 'api/api.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

BottomNavigationBar buildBottomNavigationBar(
    BuildContext context, int currentIndex, Function(int) onItemTapped) {
  final List<Widget> widgetOptions = <Widget>[
    const MainPage(),
    const FolderScreen(),
    const LearningPreparation(),
    const MyPageScreen(),
  ];

  final List<FocusNode> focusNodes =
      List.generate(widgetOptions.length, (_) => FocusNode());

  void handleItemTap(int index) {
    onItemTapped(index);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          focusNodes[index].requestFocus();
        });
        return Focus(
          focusNode: focusNodes[index],
          child: widgetOptions[index],
        );
      }),
    );
  }

  return BottomNavigationBar(
    currentIndex: currentIndex,
    showUnselectedLabels: true,
    backgroundColor: Colors.white,
    type: BottomNavigationBarType.fixed,
    onTap: handleItemTap,
    items: [
      buildBottomNavigationBarItem(
          context, currentIndex, 0, 'assets/navigation_bar/home.png', 'HOME'),
      buildBottomNavigationBarItem(
          context, currentIndex, 1, 'assets/navigation_bar/folder.png', '폴더'),
      buildBottomNavigationBarItem(context, currentIndex, 2,
          'assets/navigation_bar/learningstart.png', '학습 시작'),
      buildBottomNavigationBarItem(context, currentIndex, 3,
          'assets/navigation_bar/mypage.png', '마이페이지'),
    ],
    selectedItemColor: Colors.teal,
    unselectedItemColor: Colors.black,
    selectedIconTheme: const IconThemeData(color: Colors.teal),
    unselectedIconTheme: const IconThemeData(color: Colors.black),
    selectedLabelStyle: const TextStyle(
      color: Colors.teal,
      fontSize: 9,
      fontFamily: 'DM Sans',
      fontWeight: FontWeight.bold,
    ),
    unselectedLabelStyle: const TextStyle(
      color: Colors.black,
      fontSize: 9,
      fontFamily: 'DM Sans',
      fontWeight: FontWeight.bold,
    ),
  );
}

BottomNavigationBarItem buildBottomNavigationBarItem(BuildContext context,
    int currentIndex, int index, String iconPath, String label) {
  final bool isSelected = currentIndex == index;

  return BottomNavigationBarItem(
    icon: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ImageIcon(
          AssetImage(iconPath),
          color: isSelected ? Colors.teal : Colors.black,
        ),
        const SizedBox(height: 4), // 아이콘과 라벨 사이의 간격 조정
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.teal : Colors.black,
            fontSize: 9,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isSelected)
          Container(
            margin: const EdgeInsets.only(top: 2),
            height: 2,
            width: 40, // 바의 길이를 조정
            color: Colors.teal,
          ),
      ],
    ),
    label: '',
  );
}

Future<List<Map<String, String>>> fetchFolders() async {
  final response =
      await http.get(Uri.parse('http://localhost:3000/api/lecture-folders'));

  if (response.statusCode == 200) {
    final List<dynamic> folderList = json.decode(response.body);
    return folderList.map((folder) {
      return {
        'id': folder['id'].toString(),
        'name': folder['folder_name'].toString(),
      };
    }).toList();
  } else {
    throw Exception('Failed to load folders');
  }
}

//showQuickMenu 함수
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
                      child: CustomCheckbox(
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

// CONFIRM ALEART 1,2
void showConfirmationDialog(
  BuildContext context,
  String title,
  String content,
  VoidCallback onConfirm,
) {
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode contentFocusNode = FocusNode();
  final FocusNode cancelFocusNode = FocusNode();
  final FocusNode confirmFocusNode = FocusNode();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Semantics(
        label: '녹음을 종료하시겠습니까?',
        child: AlertDialog(
          backgroundColor: Colors.white,
          title: Semantics(
            sortKey: OrdinalSortKey(1.0),
            child: Focus(
              focusNode: titleFocusNode,
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF545454),
                  fontSize: 14,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          content: Semantics(
            sortKey: OrdinalSortKey(2.0),
            child: Focus(
              focusNode: contentFocusNode,
              child: Text(
                content,
                style: const TextStyle(
                  color: Color(0xFF245B3A),
                  fontSize: 11,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w200,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          actions: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    sortKey: OrdinalSortKey(3.0),
                    child: Focus(
                      focusNode: cancelFocusNode,
                      child: TextButton(
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
                    ),
                  ),
                  Semantics(
                    sortKey: OrdinalSortKey(4.0),
                    child: Focus(
                      focusNode: confirmFocusNode,
                      child: TextButton(
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
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );

  // 다음 프레임에서 포커스를 타이틀에 설정합니다.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FocusScope.of(context).requestFocus(titleFocusNode);
  });
}

// Creating - 콜론 파일 생성중 팝업
void showColonCreatingDialog(
    BuildContext context,
    String fileName, //생성된 콜론 파일 이름
    String fileURL, //강의자료 url
    ValueNotifier<double> progressNotifier) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '콜론 파일을 생성 중입니다',
              style: TextStyle(
                color: Color(0xFF414141),
                fontSize: 16,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF36AE92)),
              strokeWidth: 4.0,
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<double>(
              valueListenable: progressNotifier,
              builder: (context, value, child) {
                return Text(
                  '${(value * 100).toStringAsFixed(0)}%', // 진행률을 퍼센트로 표시
                  style: const TextStyle(
                    color: Color(0xFF414141),
                    fontSize: 16,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

// // 콜론 폴더 생성 및 파일 생성 함수
// Future<int> createColonFolder(String folderName, String noteName,
//     String fileUrl, String lectureName, int userKey) async {
//   var url = '${API.baseUrl}/api/create-colon';

//   var body = {
//     'folderName': folderName,
//     'noteName': noteName,
//     'fileUrl': fileUrl,
//     'lectureName': lectureName,
//     'userKey': userKey,
//   };

//   try {
//     print('Sending request to $url with body: $body');

//     var response = await http.post(
//       Uri.parse(url),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(body),
//     );

//     if (response.statusCode == 200) {
//       var jsonResponse = jsonDecode(response.body);
//       print('Folder and file created successfully');
//       print('Colon File ID: ${jsonResponse['colonFileId']}');
//       return jsonResponse['colonFileId'];
//       //return jsonResponse['folder_id'];
//     } else {
//       print('Failed to create folder and file: ${response.statusCode}');
//       print('Response body: ${response.body}');
//       return -1;
//     }
//   } catch (e) {
//     print('Error during HTTP request: $e');
//     return -1;
//   }
// }

// 콜론 생성 다이얼로그 함수
void showColonCreatedDialog(BuildContext context, String folderName,
    String noteName, String lectureName, String fileUrl, int? lectureFileId) {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userKey = userProvider.user?.userKey;

  if (userKey != null) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Column(
            children: [
              const Text(
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
                '폴더 이름: $folderName (:)', // 기본폴더 대신 folderName 사용
                style: const TextStyle(
                  color: Color(0xFF245B3A),
                  fontSize: 14,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
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
                      Navigator.of(dialogContext).pop();
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
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();

                      // // 폴더 및 파일 생성
                      // int colonFileId = await createColonFolder(
                      //   "$folderName (:)",
                      //   "$noteName (:)",
                      //   fileUrl,
                      //   lectureName,
                      //   userKey
                      // );
                      // if (colonFileId != -1) {
                      //   // Update LectureFiles with colonFileId
                      //   //_lectureFileId를 가져와야 함

                      //   await updateLectureFileWithColonId(lectureFileId, colonFileId);

                      //    // Record_Table 업데이트 : 새로 생성된 colonFileId를 연결
                      //   await _updateRecordTableWithColonId(lectureFileId, colonFileId);

                      //   // `ColonPage`로 이동전 콜론 정보 가져오기
                      //   var colonDetails = await _fetchColonDetails(colonFileId);

                      //   //ColonFiles에 folder_id로 폴더 이름 가져오기
                      //   var colonFolderName = await _fetchColonFolderName(colonDetails['folder_id']);

                      //   // 다이얼로그가 닫힌 후에 네비게이션을 실행
                      //   Future.delayed(Duration(milliseconds: 200), () {
                      //     _navigateToColonPage(context, colonFolderName, noteName, lectureName, colonDetails['created_at']);
                      //   });
                      // } else {
                      //   print('Failed to fetch colon file details:');
                      // }
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
  } else {
    print('User Key is null, cannot create colon folder.');
  }
}

// Learning - 강의 자료 학습중 팝업
void showLearningDialog(BuildContext context, String fileName, String fileURL,
    ProgressNotifier progressNotifier) {
  // 변경된 부분: ProgressNotifier로 타입 변경
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<double>(
              valueListenable: progressNotifier,
              builder: (context, value, child) {
                return Column(
                  children: [
                    Text(
                      progressNotifier.message, // 메시지 표시
                      style: const TextStyle(
                        color: Color(0xFF414141),
                        fontSize: 16,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF36AE92)),
                      strokeWidth: 4.0,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${(value * 100).toStringAsFixed(0)}%', // 진행률을 퍼센트로 표시
                      style: const TextStyle(
                        color: Color(0xFF414141),
                        fontSize: 16,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
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

Future<void> showCustomMenu2(
    BuildContext context, VoidCallback onRename, VoidCallback onDelete) async {
  final RenderBox button = context.findRenderObject() as RenderBox;
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;

  final Offset buttonPosition =
      button.localToGlobal(Offset.zero, ancestor: overlay);
  final double left = buttonPosition.dx;
  final double top = buttonPosition.dy + button.size.height;

  await showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(left + button.size.width, top, left, top),
    items: [
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
    ],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    color: Colors.white,
  ).then((value) {
    if (value == 'delete') {
      onDelete();
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

// 이름 바꾸기1 : 폴더&파일
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

// 폴더 페이지 - 햄버거 - 이름바꾸기
Future<void> showRenameDialogVer2(
    BuildContext context,
    int index,
    List<Map<String, dynamic>> items,
    String folderType, // 폴더 타입 추가
    Future<void> Function(String, int, String) renameItem,
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
        backgroundColor: Colors.white,
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
          decoration: InputDecoration(
              hintText: items[index][itemType],
              hintStyle:
                  const TextStyle(color: Color.fromARGB(255, 85, 85, 85))),
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
              await renameItem(
                  folderType, items[index]['id'], nameController.text);
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
        backgroundColor: Colors.white,
        title: const Text(
          '새 폴더 만들기',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF545454)),
        ),
        content: TextField(
          controller: folderNameController,
          decoration: const InputDecoration(
            hintText: '폴더 이름',
            hintStyle: TextStyle(color: Color.fromRGBO(110, 110, 110, 1.0)),
          ),
          style: const TextStyle(
            color: Color(0xFF545454),
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

// 체크박스
class CustomCheckbox extends StatefulWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onChanged;

  const CustomCheckbox({
    super.key,
    required this.label,
    this.isSelected = false,
    required this.onChanged,
  });

  @override
  _CustomCheckboxState createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
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
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: isSelected ? Colors.teal : Colors.transparent,
              border: Border.all(
                color: const Color.fromARGB(255, 80, 80, 80), // 테두리 색상
                width: 1.6,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 16, // 텍스트 크기 지정
              fontFamily: 'DM Sans',
              color: Color.fromARGB(255, 70, 70, 70), // 텍스트 색상 지정
              fontWeight: FontWeight.w500, // 텍스트 두께 지정
            ),
          ),
        ],
      ),
    );
  }
}

class CustomRadioButton extends StatefulWidget {
  final String label;
  final bool value;
  final bool groupValue;
  final Function(bool?) onChanged;

  const CustomRadioButton({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  _CustomRadioButtonState createState() => _CustomRadioButtonState();
}

class _CustomRadioButtonState extends State<CustomRadioButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(widget.value);
      },
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: widget.value == widget.groupValue
                  ? Colors.teal
                  : Colors.transparent,
              border: Border.all(
                color: const Color.fromARGB(255, 80, 80, 80),
                width: 1.6,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: widget.value == widget.groupValue
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'DM Sans',
              color: Color.fromARGB(255, 70, 70, 70),
              fontWeight: FontWeight.w200,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomRadioButton2 extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  const CustomRadioButton2({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!isSelected);
      },
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: isSelected ? Colors.teal : Colors.transparent,
              border: Border.all(
                color: const Color.fromARGB(255, 80, 80, 80),
                width: 1.6,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'DM Sans',
                color: Color.fromARGB(255, 70, 70, 70),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis, // 텍스트 오버플로우 처리
            ),
          ),
        ],
      ),
    );
  }
}

// Checkbox2 위젯
// class Checkbox2 extends StatefulWidget {
//   final String label;
//   final bool isSelected;
//   final Function(bool) onChanged;

//   const Checkbox2({
//     super.key,
//     required this.label,
//     this.isSelected = false,
//     required this.onChanged,
//   });

//   @override
//   _Checkbox2State createState() => _Checkbox2State();
// }

// class _Checkbox2State extends State<Checkbox2> {
//   late bool isSelected;

//   @override
//   void initState() {
//     super.initState();
//     isSelected = widget.isSelected;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           isSelected = !isSelected;
//         });
//         widget.onChanged(isSelected);
//       },
//       child: Row(
//         children: [
//           Checkbox(
//             value: isSelected,
//             onChanged: (value) {
//               setState(() {
//                 isSelected = value!;
//               });
//               widget.onChanged(isSelected);
//             },
//           ),
//           Text(widget.label),
//         ],
//       ),
//     );
//   }
// }

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
                    Expanded(
                      child: Text(
                        lectureName,
                        style: const TextStyle(
                          color: Color(0xFF1F1F39),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
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
                    child: Semantics(
                      label: '파일 메뉴 버튼',
                      child: ImageIcon(
                        AssetImage('assets/folder_menu.png'),
                        color: Color.fromRGBO(255, 161, 122, 1),
                      ),
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
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final String? iconPath;
  final IconData? iconData;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool isDisabled;

  const ClickButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width = double.infinity,
    this.height = 50.0,
    this.iconPath,
    this.iconData,
    this.iconColor,
    this.backgroundColor,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: isDisabled ? null : onPressed,
        child: Container(
          width: width,
          height: height,
          decoration: ShapeDecoration(
            color: isDisabled
                ? Colors.grey
                : (backgroundColor ?? const Color.fromRGBO(54, 174, 146, 1.0)),
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

// 폴더 리스트
class FolderListItem extends StatelessWidget {
  final Map<String, dynamic> folder;
  final int fileCount; // 추가된 파일 개수 필드
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const FolderListItem({
    super.key,
    required this.folder,
    required this.fileCount, // 추가된 파일 개수 필드
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
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(204, 227, 205, 1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.folder_rounded,
                color: Color.fromARGB(255, 41, 129, 108),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              folder['folder_name'],
              style: const TextStyle(
                color: Color(0xFF414141),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis, // 텍스트 오버플로우 처리
            ),
          ),
          Row(
            children: [
              Text(
                '$fileCount files',
                style: const TextStyle(
                  color: Color(0xFF005A38),
                  fontSize: 12,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                child: Semantics(
                  label: '폴더 메뉴 버튼',
                  child: ImageIcon(
                    AssetImage('assets/folder_menu.png'),
                    color: Color.fromRGBO(255, 161, 122, 1),
                  ),
                ),
                onTap: () {
                  showCustomMenu2(context, onRename, onDelete);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
