import 'package:flutter/material.dart';
import 'folder/37_folder_files_screen.dart';
import 'folder/39_folder_section.dart';
import 'folder/38_folder_list.dart';
import '31_full_folder_list_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});

  @override
  _FolderScreenState createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  List<Map<String, dynamic>> lectureFolders = [];
  List<Map<String, dynamic>> colonFolders = [];

  @override
  void initState() {
    super.initState();
    fetchFolders();
  }

  Future<void> fetchFolders() async {
    try {
      final lectureResponse = await http
          .get(Uri.parse('http://localhost:3000/api/lecture-folders'));
      final colonResponse =
          await http.get(Uri.parse('http://localhost:3000/api/colon-folders'));

      if (lectureResponse.statusCode == 200 &&
          colonResponse.statusCode == 200) {
        setState(() {
          lectureFolders =
              List<Map<String, dynamic>>.from(jsonDecode(lectureResponse.body));
          colonFolders =
              List<Map<String, dynamic>>.from(jsonDecode(colonResponse.body));
        });
      } else {
        throw Exception('Failed to load folders');
      }
    } catch (e) {
      print(e);
      // 오류 처리 로직 추가 가능
    }
  }

  Future<void> _addFolder(String folderName, String folderType) async {
    final url = Uri.parse(
        'http://localhost:3000/api/${folderType == 'lecture' ? 'lecture' : 'colon'}-folders');
    try {
      final response = await http.post(url,
          body: jsonEncode({'folder_name': folderName}),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final newFolder = jsonDecode(response.body);
        setState(() {
          if (folderType == 'lecture') {
            lectureFolders.add(newFolder);
          } else {
            colonFolders.add(newFolder);
          }
        });
      } else {
        throw Exception('Failed to add folder');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _renameFolder(String folderType, int id, String newName) async {
    final url = Uri.parse(
        'http://localhost:3000/api/${folderType == 'lecture' ? 'lecture' : 'colon'}-folders/$id');
    try {
      final response = await http.put(url,
          body: jsonEncode({'folder_name': newName}),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode != 200) {
        throw Exception('Failed to rename folder');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _deleteFolder(String folderType, int id) async {
    final url = Uri.parse(
        'http://localhost:3000/api/${folderType == 'lecture' ? 'lecture' : 'colon'}-folders/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to delete folder');
      }
    } catch (e) {
      print(e);
    }
  }

  void _showAddFolderDialog(BuildContext context, String folderType) {
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
                _addFolder(folderNameController.text, folderType);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showRenameFolderDialog(BuildContext context, int index,
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
                await _renameFolder(folderType, folderList[index]['id'],
                    folderNameController.text);
                setState(() {
                  folderList[index]['folder_name'] = folderNameController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteFolderDialog(BuildContext context, int index,
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
                await _deleteFolder(folderType, folderList[index]['id']);
                setState(() {
                  folderList.removeAt(index);
                });
                Navigator.of(context).pop();
                _showDeletionConfirmation(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeletionConfirmation(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경 색상을 흰색으로 설정
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FolderSection(
                    sectionTitle: '강의폴더',
                    onAddPressed: () {
                      _showAddFolderDialog(context, 'lecture');
                    },
                    onViewAllPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullFolderListScreen(
                            folders: lectureFolders,
                            title: '강의폴더',
                          ),
                        ),
                      );
                    },
                  ),
                  FolderList(
                    folders: lectureFolders.take(3).toList(),
                    onFolderTap: (folder) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FolderFilesScreen(
                            folderName: folder['folder_name'],
                            folderId: folder['id'],
                            folderType: 'lecture',
                          ),
                        ),
                      );
                    },
                    onRename: (index) => _showRenameFolderDialog(
                        context, index, lectureFolders, 'lecture'),
                    onDelete: (index) => _showDeleteFolderDialog(
                        context, index, lectureFolders, 'lecture'),
                  ),
                  const SizedBox(height: 20),
                  FolderSection(
                    sectionTitle: '콜론폴더',
                    onAddPressed: () {
                      _showAddFolderDialog(context, 'colon');
                    },
                    onViewAllPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullFolderListScreen(
                            folders: colonFolders,
                            title: '콜론폴더',
                          ),
                        ),
                      );
                    },
                  ),
                  FolderList(
                    folders: colonFolders.take(3).toList(),
                    onFolderTap: (folder) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FolderFilesScreen(
                            folderName: folder['folder_name'],
                            folderId: folder['id'],
                            folderType: 'colon',
                          ),
                        ),
                      );
                    },
                    onRename: (index) => _showRenameFolderDialog(
                        context, index, colonFolders, 'colon'),
                    onDelete: (index) => _showDeleteFolderDialog(
                        context, index, colonFolders, 'colon'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
