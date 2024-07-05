import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../35_rename_delete_popup.dart';
import 'package:intl/intl.dart'; // 이 라인을 추가합니다.

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

  @override
  void initState() {
    super.initState();
    fetchFiles();
  }

  Future<void> fetchFiles() async {
    final response = await http.get(Uri.parse(
      'http://localhost:3000/api/${widget.folderType}-files/${widget.folderId}',
    ));

    if (response.statusCode == 200) {
      final List<dynamic> fileData = jsonDecode(response.body);
      setState(() {
        files = fileData.map((file) {
          return {
            'file_name': file['file_name'] ?? 'Unknown',
            'file_url': file['file_url'] ?? '',
            'created_at': file['created_at'] ?? '',
          };
        }).toList();
      });
    } else {
      throw Exception('Failed to load files');
    }
  }

  String formatDateTime(String dateTime) {
    if (dateTime.isEmpty) return 'Unknown';
    final DateTime parsedDateTime = DateTime.parse(dateTime);
    return DateFormat('yyyy/MM/dd HH:mm').format(parsedDateTime);
  }

  void _renameFile(BuildContext context, int index) {
    final TextEditingController fileNameController =
        TextEditingController(text: files[index]['file_name']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '파일 이름 바꾸기',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF545454)),
          ),
          content: TextField(
            controller: fileNameController,
            decoration: const InputDecoration(hintText: '파일 이름'),
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
                '저장',
                style: TextStyle(
                    color: Color(0xFF545454), fontWeight: FontWeight.w700),
              ),
              onPressed: () {
                setState(() {
                  files[index]['file_name'] = fileNameController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteFile(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('파일 삭제하기'),
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
              onPressed: () {
                setState(() {
                  files.removeAt(index);
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
                    onRename: () => _renameFile(context, index),
                    onDelete: () => _deleteFile(context, index),
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

  String formatDateTime(String dateTime) {
    if (dateTime.isEmpty) return 'Unknown';
    final DateTime parsedDateTime = DateTime.parse(dateTime);
    return DateFormat('yyyy/MM/dd HH:mm').format(parsedDateTime);
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
                formatDateTime(file['created_at'] ?? ''),
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
