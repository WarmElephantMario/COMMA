import 'package:flutter/material.dart';
import '../30_folder_screen.dart';
import '../35_rename_delete_popup.dart';

class FolderFilesScreen extends StatefulWidget {
  final String folderName;

  const FolderFilesScreen({required this.folderName});

  @override
  State<FolderFilesScreen> createState() => _FolderFilesScreenState();
}

class _FolderFilesScreenState extends State<FolderFilesScreen> {
  List<Map<String, String>> files = [
    {'name': '새로운 노트', 'date': '2024/06/07', 'time': '오후 2:30'},
    {'name': '프로젝트 계획', 'date': '2024/06/05', 'time': '오전 11:00'},
    {'name': '회의록', 'date': '2024/06/04', 'time': '오전 9:00'},
  ];

  void _renameFile(BuildContext context, int index) {
    final TextEditingController _fileNameController =
        TextEditingController(text: files[index]['name']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('파일 이름 바꾸기',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF545454)
          ),
          ),
          content: TextField(
            controller: _fileNameController,
            decoration: const InputDecoration(hintText: '파일 이름'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소',
                  style: TextStyle(
                    color: Color(0xFFFFA17A),
                    fontWeight: FontWeight.w700
                  )
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('저장',
              style: TextStyle(
                color: Color(0xFF545454),
                fontWeight: FontWeight.w700
              ),),
              onPressed: () {
                setState(() {
                  files[index]['name'] = _fileNameController.text;
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
          title: Text('파일 삭제하기'),
          content: Text('정말로 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('취소', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('삭제'),
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
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text('삭제되었습니다.',
                    style: TextStyle(
                      color: Color(0xFF545454),
                      fontWeight: FontWeight.w800
                    ),),
                    trailing: TextButton(
                      child: Text(
                        '확인',
                        style: TextStyle(
                          color: Color(0xFFFFA17A),
                          fontWeight: FontWeight.w700
                        ),
                      ),
                      onPressed: () {
                        if(overlayEntry != null){
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
      appBar: AppBar(
        title: Text(widget.folderName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: files.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, String> file = entry.value;
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
  final Map<String, String> file;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const FileListItem({
    required this.file,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
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
              color: Color(0xFF0D5836),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              file['name']!,
              style: TextStyle(
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
                file['date']!,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6C7A89),
                ),
              ),
              SizedBox(height: 5),
              Text(
                file['time']!,
                style: TextStyle(
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
