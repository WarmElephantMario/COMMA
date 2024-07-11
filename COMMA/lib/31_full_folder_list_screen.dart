import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_plugin/components.dart';
import 'package:provider/provider.dart';
import '../model/user_provider.dart';
import 'folder/37_folder_files_screen.dart'; // FolderFilesScreen이 정의된 파일 임포트
import 'api/api.dart';

class FullFolderListScreen extends StatefulWidget {
  final String title;

  const FullFolderListScreen({
    super.key,
    required this.title,
  });

  @override
  _FullFolderListScreenState createState() => _FullFolderListScreenState();
}

class _FullFolderListScreenState extends State<FullFolderListScreen> {
  List<Map<String, dynamic>> folders = [];
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchFolders();
  }

  Future<void> fetchFolders() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userKey = userProvider.user?.userKey;

    if (userKey != null) {
      final String folderType = widget.title == '강의폴더' ? 'lecture' : 'colon';
      final response = await http.get(
        Uri.parse(
            '${API.baseUrl}/api/$folderType-folders?userKey=$userKey'),
      );

      if (response.statusCode == 200) {
        setState(() {
          folders = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      } else {
        throw Exception('Failed to load folders');
      }
    }
  }

  Future<void> _addFolder(String folderName) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userKey = userProvider.user?.userKey;

    if (userKey != null) {
      final String folderType = widget.title == '강의폴더' ? 'lecture' : 'colon';
      try {
        final response = await http.post(
          Uri.parse('${API.baseUrl}/api/$folderType-folders'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'folder_name': folderName,
            'userKey': userKey,
          }),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> newFolder = jsonDecode(response.body);
          setState(() {
            folders.add(newFolder);
          });
        }
      } catch (e) {
        throw Exception('Failed to add folder');
      }
    }
  }

  Future<void> _renameFolder(int id, String newName) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userKey = userProvider.user?.userKey;

    if (userKey != null) {
      final String folderType = widget.title == '강의폴더' ? 'lecture' : 'colon';
      try {
        final response = await http.put(
          Uri.parse('${API.baseUrl}/api/$folderType-folders/$id'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'folder_name': newName,
            'userKey': userKey,
          }),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to rename folder');
        }
      } catch (e) {
        throw Exception('Failed to rename folder');
      }
    }
  }

  Future<void> _deleteFolder(int id) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userKey = userProvider.user?.userKey;

    if (userKey != null) {
      final String folderType = widget.title == '강의폴더' ? 'lecture' : 'colon';
      try {
        final response = await http.delete(
          Uri.parse('${API.baseUrl}/api/$folderType-folders/$id'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'userKey': userKey,
          }),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to delete folder');
        }
      } catch (e) {
        throw Exception('Failed to delete folder');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: TextButton(
              onPressed: () {
                showAddFolderDialog(context, _addFolder);
              },
              child: Row(
                children: [
                  const Text(
                    '추가하기',
                    style: TextStyle(
                      color: Color(0xFF36AE92),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Image.asset('assets/add2.png'),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: folders.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> folder = entry.value;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FolderFilesScreen(
                            folderName: folder['folder_name'],
                            folderId: folder['id'],
                            folderType:
                                widget.title == '강의폴더' ? 'lecture' : 'colon',
                          ),
                        ),
                      );
                    },
                    child: FolderListItem(
                      folder: folder,
                      fileCount: folder['file_count'] ?? 0, // 파일 개수 전달
                      onRename: () => showRenameDialog(
                        context,
                        index,
                        folders,
                        _renameFolder,
                        setState,
                        "폴더 이름 바꾸기", // 다이얼로그 제목
                        "folder_name", // 변경할 항목 타입
                      ),
                      onDelete: () => showConfirmationDialog(
                        context,
                        "정말로 폴더 '${folder['folder_name']}'을(를) 삭제하시겠습니까?", // 다이얼로그 제목
                        "폴더를 삭제하면 다시 복구할 수 없습니다.", // 다이얼로그 내용
                        () async {
                          await _deleteFolder(folder['id']);
                          setState(() {
                            folders.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar:
          buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}
