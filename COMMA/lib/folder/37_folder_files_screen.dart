import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_plugin/components.dart';
import 'package:flutter_plugin/30_folder_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/user_provider.dart';

class FolderFilesScreen extends StatefulWidget {
  final String folderName;
  final int folderId; // 폴더 ID를 추가로 받습니다.
  final String folderType; // 'lecture' 또는 'colon'

  const FolderFilesScreen({
    super.key,
    required this.folderName,
    required this.folderId, // 폴더 ID
    required this.folderType, // 폴더 타입
  });

  @override
  State<FolderFilesScreen> createState() => _FolderFilesScreenState();
}

class _FolderFilesScreenState extends State<FolderFilesScreen> {
  List<Map<String, dynamic>> files = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchFiles();
  }

  Future<void> fetchFiles() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.user_id;

    if (userId != null) {
      final response = await http.get(Uri.parse(
        'http://localhost:3000/api/${widget.folderType}-files/${widget.folderId}?user_id=$userId',
      ));

      if (response.statusCode == 200) {
        final List<dynamic> fileData = jsonDecode(response.body);
        setState(() {
          files = fileData.map((file) {
            return {
              'file_name': file['file_name'] ?? 'Unknown',
              'file_url': file['file_url'] ?? '',
              'created_at': file['created_at'] ?? '',
              'id': file['id'] // 파일 ID 추가
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load files');
      }
    }
  }

  Future<void> _renameFile(int id, String newName) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.user_id;

    if (userId != null) {
      final url =
          Uri.parse('http://localhost:3000/api/${widget.folderType}-files/$id');
      try {
        final response = await http.put(url,
            body: jsonEncode({'file_name': newName, 'user_id': userId}),
            headers: {'Content-Type': 'application/json'});
        if (response.statusCode != 200) {
          throw Exception('Failed to rename file');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _deleteFile(int id) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.user_id;

    if (userId != null) {
      final url =
          Uri.parse('http://localhost:3000/api/${widget.folderType}-files/$id');
      try {
        final response = await http.delete(url,
            body: jsonEncode({'user_id': userId}),
            headers: {'Content-Type': 'application/json'});
        if (response.statusCode != 200) {
          throw Exception('Failed to delete file');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String formatDateTime(String dateTime) {
    if (dateTime.isEmpty) return 'Unknown';
    final DateTime parsedDateTime = DateTime.parse(dateTime);
    return DateFormat('yyyy/MM/dd HH:mm').format(parsedDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.folderName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: files.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> file = entry.value;
                  return FileListItem(
                    file: file,
                    onRename: () => showRenameDialog(
                        context,
                        index,
                        files,
                        (id, newName) => _renameFile(id, newName),
                        setState,
                        "파일 이름 바꾸기", // 다이얼로그 제목
                        "file_name" // 변경할 항목 타입
                        ),
                    onDelete: () => showConfirmationDialog(
                        context, "정말 파일을 삭제하시겠습니까?", "파일을 삭제하면 다시 복구할 수 없습니다.",
                        () async {
                      await _deleteFile(file['id']);
                      setState(() {
                        files.removeAt(index);
                      });
                    }),
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

class FileListItem extends StatelessWidget {
  final Map<String, dynamic> file;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const FileListItem({
    super.key,
    required this.file,
    required this.onRename,
    required this.onDelete,
  });

  String formatDateTimeToKorean(String dateTime) {
    if (dateTime.isEmpty) return 'Unknown';
    final DateTime utcDateTime = DateTime.parse(dateTime);
    final DateTime koreanDateTime = utcDateTime.add(const Duration(hours: 9));
    return DateFormat('yyyy/MM/dd HH:mm').format(koreanDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 2.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0D5836),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              file['file_name'] ?? 'Unknown',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                formatDateTimeToKorean(file['created_at'] ?? ''),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6C7A89),
                ),
              ),
            ],
          ),
          RenameDeletePopup(
            onRename: onRename,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }
}
