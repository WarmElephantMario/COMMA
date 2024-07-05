import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'folder/37_folder_files_screen.dart';
import '35_rename_delete_popup.dart';

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

  @override
  void initState() {
    super.initState();
    folders = widget.folders;
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

  void _showAddFolderDialog(BuildContext context) {
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
                await _addFolder(folderNameController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showRenameFolderDialog(BuildContext context, int index) {
    final TextEditingController folderNameController =
        TextEditingController(text: folders[index]['folder_name']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('폴더 이름 바꾸기'),
          content: TextField(
            controller: folderNameController,
            decoration: const InputDecoration(hintText: '폴더 이름'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('저장'),
              onPressed: () async {
                await _renameFolder(
                    folders[index]['id'], folderNameController.text);
                setState(() {
                  folders[index]['folder_name'] = folderNameController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteFolderDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('폴더 삭제하기'),
          content: const Text('정말로 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('삭제'),
              onPressed: () async {
                await _deleteFolder(folders[index]['id']);
                setState(() {
                  folders.removeAt(index);
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
                _showAddFolderDialog(context);
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
                      onRename: () => _showRenameFolderDialog(context, index),
                      onDelete: () => _showDeleteFolderDialog(context, index),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

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
