import 'package:flutter/material.dart';
import 'components.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'folder/37_folder_files_screen.dart';

class FullFolderListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> folders;
  final String title;

  const FullFolderListScreen({
    super.key,
    required this.folders,
    required this.title,
  });

  @override
  _FullFolderListScreenState createState() => _FullFolderListScreenState();
}

class _FullFolderListScreenState extends State<FullFolderListScreen> {
  late List<Map<String, dynamic>> folders;
  late List<Map<String, dynamic>> colonFolders;

  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    folders = widget.folders;
    colonFolders = folders.where((folder) => folder['type'] == 'colon').toList();
  }

  Future<void> _addFolder(String folderName) async {
    final String folderType = widget.title == '강의폴더' ? 'lecture' : 'colon';
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/$folderType-folders'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'folder_name': folderName,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> newFolder = jsonDecode(response.body);
        setState(() {
          folders.add(newFolder);
          if (folderType == 'colon') {
            colonFolders.add(newFolder);
          }
        });
      }
    } catch (e) {
      throw Exception('Failed to add folder');
    }
  }

  Future<void> _renameFolder(int id, String newName) async {
    final String folderType = widget.title == '강의폴더' ? 'lecture' : 'colon';
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/api/$folderType-folders/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'folder_name': newName,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to rename folder');
      }
    } catch (e) {
      throw Exception('Failed to rename folder');
    }
  }

  Future<void> _deleteFolder(int id) async {
    final String folderType = widget.title == '강의폴더' ? 'lecture' : 'colon';
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/api/$folderType-folders/$id'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete folder');
      }
    } catch (e) {
      throw Exception('Failed to delete folder');
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
                        "정말로 폴더 '${colonFolders[index]['name']}'을(를) 삭제하시겠습니까?", // 다이얼로그 제목
                        "폴더를 삭제하면 다시 복구할 수 없습니다.", // 다이얼로그 내용
                        () async {
                          await _deleteFolder(colonFolders[index]['id']);
                          setState(() {
                            colonFolders.removeAt(index);
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
      bottomNavigationBar: buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}
