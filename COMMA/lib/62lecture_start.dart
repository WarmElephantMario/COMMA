import 'package:flutter/material.dart';
import 'package:flutter_plugin/model/user.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'components.dart';
import '63record.dart';
import 'package:provider/provider.dart';
import 'model/user_provider.dart';
import 'api/api.dart';

class LectureStartPage extends StatefulWidget {
  final String fileName;
  final String fileURL;
  final String responseUrl;
  final int type;


  const LectureStartPage({
    Key? key,
    required this.fileName,
    required this.fileURL,
    required this.responseUrl,
    required this.type,
  }) : super(key: key);

  @override
  _LectureStartPageState createState() => _LectureStartPageState();
}

class _LectureStartPageState extends State<LectureStartPage> {
  int _selectedIndex = 2;
  String _selectedFolder = '폴더';
  String _noteName = '새로운 노트';
  List<Map<String, dynamic>> folderList = [];
  List<Map<String, dynamic>> items = [];
  

  @override

void initState() {
  super.initState();
  // 기본 폴더 ID를 설정 (예: -1)
  int currentFolderId = -1;
  fetchFolderList(currentFolderId);
}


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

 Future<void> fetchFolderList(int currentFolderId) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userKey = userProvider.user?.userKey;

  if (userKey != null) {
    try {
      // currentFolderId를 쿼리 파라미터로 포함
      final uri = Uri.parse('${API.baseUrl}/api/lecture-folders?userKey=$userKey&currentFolderId=$currentFolderId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> folderData = json.decode(response.body);

        setState(() {
          // 현재 선택된 폴더를 제외하고 나머지 폴더 목록 업데이트
          folderList = folderData
              .map((folder) => {
                    'id': folder['id'],
                    'folder_name': folder['folder_name'],
                    'selected': false,
                  })
              .toList();

          var defaultFolder = folderList.firstWhere(
              (folder) => folder['folder_name'] == '기본 폴더',
              orElse: () => <String, dynamic>{});
          if (defaultFolder.isNotEmpty) {
            _selectFolder(defaultFolder['folder_name']);
          }
        });
      } else {
        throw Exception('Failed to load folders');
      }
    } catch (e) {
      print('Folder list fetch failed: $e');
    }
  } else {
    print('User Key is null, cannot fetch folders.');
  }
}






  void _selectFolder(String folderName) {
    setState(() {
      _selectedFolder = folderName;
    });
  }

 Future<void> fetchOtherFolders(String fileType, int currentFolderId) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userKey = userProvider.user?.userKey;

  if (userKey != null) {
    try {
      final uri = Uri.parse(
          '${API.baseUrl}/api/getOtherFolders/$fileType/$currentFolderId?userKey=$userKey');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> fetchedFolders =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));

        setState(() {
          // 기존의 폴더 리스트를 업데이트하는 대신, fetchedFolders를 사용합니다.
          folderList = fetchedFolders;
          folderList.removeWhere((folder) => folder['id'] == currentFolderId);
        });
      } else {
        throw Exception(
            'Failed to load folders with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching other folders: $e');
      rethrow;
    }
  } else {
    print('User Key is null, cannot fetch folders.');
  }
}

  Future<void> renameItem(String newName) async {
    setState(() {
      _noteName = newName;
    });
  }

  int getFolderIdByName(String folderName) {
    return folderList.firstWhere(
        (folder) => folder['folder_name'] == folderName,
        orElse: () => {'id': -1})['id'];
  }

void showQuickMenu(
    BuildContext context,
    Future<void> Function() fetchOtherFolders,
    List<Map<String, dynamic>> folders,
    Function(String) selectFolder) async {
  print('Attempting to fetch other folders.');
  await fetchOtherFolders();
  print('Updating folders with selection state.');

  // updatedFolders는 fetchOtherFolders 호출 후 업데이트된 folderList를 사용합니다.
  var updatedFolders = folderList.map((folder) {
    bool isSelected = folder['folder_name'] == _selectedFolder;
    return {
      ...folder,
      'selected': isSelected,
    };
  }).toList();

  print('Updated folders: $updatedFolders');

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
                        final selectedFolder = updatedFolders.firstWhere(
                            (folder) => folder['selected'] == true,
                            orElse: () => {});
                        if (selectedFolder.isNotEmpty) {
                          selectFolder(selectedFolder['folder_name']);
                        }
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
                    '다른 폴더로 이동할 수 있어요.',
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
                  children: updatedFolders.map((folder) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: CustomCheckbox(
                        label: folder['folder_name'],
                        isSelected: folder['selected'] ?? false,
                        onChanged: (bool isSelected) {
                          setState(() {
                            for (var f in updatedFolders) {
                              f['selected'] = false;
                            }
                            folder['selected'] = isSelected;
                          });
                          print('Folder selected: ${folder['folder_name']}');
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



  // 파일 이름 바꾸기 다이얼로그
  void showRenameDialog2(
    BuildContext context,
    String currentName,
    Future<void> Function(String) renameItem,
    void Function(VoidCallback) setState,
    String title,
    String fieldName,
  ) {
    final TextEditingController textController = TextEditingController();
    textController.text = currentName;

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
          ),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: "새 이름 입력"),
          ),
          actions: <Widget>[
            TextButton(
              child:
                  const Text('취소', style: TextStyle(color: Color(0xFFFFA17A))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child:
                  const Text('저장', style: TextStyle(color: Color(0xFF545454))),
              onPressed: () async {
                String newName = textController.text;
                await renameItem(newName);
                setState(() {
                  _noteName = newName;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
      ),
body: SingleChildScrollView(
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
        '업로드 한 강의 자료의 AI 학습이 완료되었어요!\n학습을 시작하려면 강의실에 입장하세요.',
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
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.fileName,
                    style: const TextStyle(
                      color: Color(0xFF575757),
                      fontSize: 15,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 15),
      GestureDetector(
        onTap: () {
          int currentFolderId = folderList.isNotEmpty ? folderList.first['id'] : 0;
          // showQuickMenu 호출
          showQuickMenu(
            context,
            () => fetchOtherFolders('lecture', currentFolderId),
            folderList,
            _selectFolder,
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/folder_search.png'),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '폴더 분류 > $_selectedFolder',
                style: const TextStyle(
                  color: Color(0xFF575757),
                  fontSize: 12,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      GestureDetector(
        onTap: () {
          showRenameDialog2(
              context,
              _noteName,
              renameItem,
              setState,
              "파일 이름 바꾸기", // 다이얼로그 제목
              "file_name" // 변경할 항목 타입
              );
        },
        child: Row(
          children: [
            Image.asset('assets/text.png'),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _noteName,
                style: const TextStyle(
                  color: Color(0xFF575757),
                  fontSize: 12,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 100),
      Center(
        child: ClickButton(
          text: '강의실 입장하기',
          onPressed: () {
            int selectedFolderId = getFolderIdByName(_selectedFolder);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecordPage(
                  selectedFolderId: selectedFolderId.toString(),
                  noteName: _noteName,
                  fileUrl: widget.fileURL,
                  folderName: _selectedFolder,
                  recordingState: RecordingState.initial,
                  lectureName: widget.fileName,
                  responseUrl: widget.responseUrl,
                  type: widget.type,
                ),
              ),
            );
          },
          width: MediaQuery.of(context).size.width * 0.5,
          height: 50.0,
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