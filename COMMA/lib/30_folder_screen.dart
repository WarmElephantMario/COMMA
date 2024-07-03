import 'package:flutter/material.dart';
import 'folder/37_folder_files_screen.dart';
import 'folder/39_folder_section.dart';
import 'folder/38_folder_list.dart';
import '31_full_folder_list_screen.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});

  @override
  _FolderScreenState createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  List<String> lectureFolders = ['기본 폴더', '정보통신공학', '컴퓨터알고리즘', '이산수학'];
  List<String> colonFolders = [
    '기본 폴더 (:)',
    '정보통신공학 (:)',
    '컴퓨터알고리즘 (:)',
    '이산수학 (:)'
  ];

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
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AlertDialog(
              title: Text(
                '정말 \'${lectureFolders[index]}\' 을(를) 삭제하시겠습니까?',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      child: const Text('취소',
                          style: TextStyle(
                              color: Color(0xFFFFA17A),
                              fontWeight: FontWeight.w700)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    TextButton(
                      child: const Text(
                        '삭제',
                        style: TextStyle(
                            color: Color(0xFF545454),
                            fontWeight: FontWeight.w700),
                      ),
                      onPressed: () {
                        setState(() {
                          folderList.removeAt(index);
                        });
                        Navigator.of(context).pop();
                        _showDeletionConfirmation(context);
                      },
                    ),
                  ],
                ),
              ],
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
