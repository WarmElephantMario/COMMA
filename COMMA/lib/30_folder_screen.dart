import 'package:flutter/material.dart';
import 'folder/39_folder_section.dart';
import 'folder/38_folder_list.dart';
import '31_full_folder_list_screen.dart';
import 'folder/37_folder_files_screen.dart';
import 'db_helper.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});

  @override
  _FolderScreenState createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  List<String> lectureFolders = [];
  List<String> colonFolders = [];

  @override
  void initState() {
    super.initState();
    _fetchFolders();
  }

  Future<void> _fetchFolders() async {
    try {
      final lectureResults = await DBHelper.getFolders('lecture');
      final colonResults = await DBHelper.getFolders('colon');

      setState(() {
        lectureFolders = lectureResults;
        colonFolders = colonResults;
      });
    } catch (e) {
      print('Error fetching folders: $e');
    }
  }

  void _addFolder(String folderName, List<String> folderList) {
    setState(() {
      folderList.add(folderName);
    });
  }

  void _showAddFolderDialog(
      BuildContext context, Function(String) addFolderCallback) {
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
                addFolderCallback(folderNameController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _renameFolder(BuildContext context, int index, List<String> folderList) {
    final TextEditingController folderNameController =
        TextEditingController(text: folderList[index]);
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
              onPressed: () {
                setState(() {
                  folderList[index] = folderNameController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteFolder(BuildContext context, int index, List<String> folderList) {
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
              onPressed: () {
                setState(() {
                  folderList.removeAt(index);
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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FolderSection(
                  sectionTitle: '강의폴더',
                  onAddPressed: () {
                    _showAddFolderDialog(
                        context, (name) => _addFolder(name, lectureFolders));
                  },
                  onViewAllPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullFolderListScreen(
                            folders: lectureFolders, title: '강의폴더'),
                      ),
                    );
                  },
                ),
                FolderList(
                  folders: lectureFolders.take(3).toList(),
                  onFolderTap: (folderName) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FolderFilesScreen(folderName: folderName),
                      ),
                    );
                  },
                  onRename: (index) =>
                      _renameFolder(context, index, lectureFolders),
                  onDelete: (index) =>
                      _deleteFolder(context, index, lectureFolders),
                ),
                const SizedBox(height: 20),
                FolderSection(
                  sectionTitle: '콜론폴더',
                  onAddPressed: () {
                    _showAddFolderDialog(
                        context, (name) => _addFolder(name, colonFolders));
                  },
                  onViewAllPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullFolderListScreen(
                            folders: colonFolders, title: '콜론폴더'),
                      ),
                    );
                  },
                ),
                FolderList(
                  folders: colonFolders.take(3).toList(),
                  onFolderTap: (folderName) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FolderFilesScreen(folderName: folderName),
                      ),
                    );
                  },
                  onRename: (index) =>
                      _renameFolder(context, index, colonFolders),
                  onDelete: (index) =>
                      _deleteFolder(context, index, colonFolders),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
