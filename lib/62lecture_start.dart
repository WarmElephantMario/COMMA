import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'components.dart';
import '63record.dart';
import 'package:provider/provider.dart';
import 'model/user.dart';
import 'model/user_provider.dart';

class LectureStartPage extends StatefulWidget {
  final String fileName;
  final String fileURL;

  const LectureStartPage(
      {super.key, required this.fileName, required this.fileURL});

  @override
  _LectureStartPageState createState() => _LectureStartPageState();
}

class _LectureStartPageState extends State<LectureStartPage> {
  int _selectedIndex = 2;
  String _selectedFolder = '짱구';
  String _noteName = '새로운 노트';
  List<Map<String, dynamic>> folderList = [];
  List<Map<String, dynamic>> items = [
    {'id': 1, 'file_name': '새로운 노트'},
  ];

  @override
  void initState() {
    super.initState();
    fetchFolderList();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _selectFolder(String folder) {
    setState(() {
      _selectedFolder = folder;
    });
  }

  Future<void> fetchFolderList() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.user_id ?? '';

    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/api/lecture-folders/$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> folderData = json.decode(response.body);
        setState(() {
          folderList = folderData
              .map((folder) => {
                    'id': folder['id'],
                    'folder_name': folder['folder_name'],
                    'selected': false
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load folders');
      }
    } catch (e) {
      print('폴더 목록 로드 실패: $e');
    }
  }

  Future<void> fetchOtherFolders(String fileType, int currentFolderId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.user_id ?? '';

    final response = await http.get(Uri.parse(
        'http://localhost:3000/api/getOtherFolders/$fileType/$currentFolderId?user_id=$userId'));

    if (response.statusCode == 200) {
      setState(() {
        folderList = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        folderList.removeWhere((folder) => folder['id'] == currentFolderId);
      });
    } else {
      throw Exception('Failed to load folders');
    }
  }

  Future<void> moveItem(
      int fileId, int selectedFolderId, String fileType) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/api/$fileType-files/move/$fileId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'folder_id': selectedFolderId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to move file');
    }
  }

  Future<void> showQuickMenu(BuildContext context, int fileId, String fileType,
      int currentFolderId) async {
    setState(() {
      folderList.clear();
    });

    await fetchOtherFolders(fileType, currentFolderId);

    setState(() {
      folderList = folderList.map((folder) {
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
                          final selectedFolder = folderList.firstWhere(
                              (folder) => folder['selected'] == true,
                              orElse: () => {
                                    'id': -1,
                                    'folder_name': '기본 폴더'
                                  }); // 조건에 맞는 폴더가 없으면 기본값 반환
                          final selectedFolderId = selectedFolder['id'];
                          await moveItem(fileId, selectedFolderId, fileType);
                          _selectFolder(selectedFolder['folder_name']);
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
                    children: folderList.map((folder) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Checkbox2(
                          label: folder['folder_name'],
                          isSelected: folder['selected'] ?? false,
                          onChanged: (bool isSelected) {
                            setState(() {
                              for (var f in folderList) {
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

  Future<void> renameItem(int id, String newName) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/api/lecture-files/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'file_name': newName}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to rename file');
    }

    setState(() {
      _noteName = newName;
    });
  }

  int getFolderIdByName(String folderName) {
    return folderList.firstWhere(
      (folder) => folder['folder_name'] == folderName,
      orElse: () => {'id': -1}, // 조건에 맞는 폴더가 없을 때 기본값 반환
    )['id'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
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
                showQuickMenu(context, 10, 'lecture',
                    18); // fileId, fileType, currentFolderId 적절히 수정
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
                showRenameDialog(
                  context,
                  0, // 인덱스 0으로 새로운 노트 항목을 선택
                  items,
                  renameItem,
                  setState,
                  '파일 이름 바꾸기',
                  'file_name',
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
                  if (selectedFolderId == -1) {
                    print('Selected folder not found');
                    return;
                  }
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
                      ),
                    ),
                  );
                },
                width: MediaQuery.of(context).size.width * 0.5,
                height: 50.0,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}
