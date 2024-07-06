import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_plugin/components.dart';
import 'package:intl/intl.dart';


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
                    onRename: () => renameFile(context, files, index, setState),
                    onDelete: () => deleteFile(context, files, index, setState, showDeletionConfirmation),
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
