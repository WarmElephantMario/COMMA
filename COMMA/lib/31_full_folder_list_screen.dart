import 'package:flutter/material.dart';
import 'folder/37_folder_files_screen.dart';
import '35_rename_delete_popup.dart';

class FullFolderListScreen extends StatefulWidget {
  final List<String> folders;
  final String title;

  const FullFolderListScreen(
      {super.key, required this.folders, required this.title});

  @override
  _FullFolderListScreenState createState() => _FullFolderListScreenState();
}

class _FullFolderListScreenState extends State<FullFolderListScreen> {
  List<String> folders;

  _FullFolderListScreenState() : folders = [];

  @override
  void initState() {
    super.initState();
    folders = widget.folders;
  }

  void _addFolder(BuildContext context) {
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
                setState(() {
                  folders.add(folderNameController.text);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _renameFolder(BuildContext context, int index) {
    final TextEditingController folderNameController =
        TextEditingController(text: folders[index]);
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
                  folders[index] = folderNameController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteFolder(BuildContext context, int index) {
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
                _addFolder(context);
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: folders.asMap().entries.map((entry) {
                  int index = entry.key;
                  String folder = entry.value;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FolderFilesScreen(folderName: folder),
                        ),
                      );
                    },
                    child: FolderListItem(
                      folder: folder,
                      onRename: () => _renameFolder(context, index),
                      onDelete: () => _deleteFolder(context, index),
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
  final String folder;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const FolderListItem(
      {super.key,
      required this.folder,
      required this.onRename,
      required this.onDelete});

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
              folder,
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



// import 'package:flutter/material.dart';
// import 'folder/folder_files_screen.dart';
// import 'folder/folder_files_screen.dart';
// import 'rename_delete_popup.dart';
//
// class FullFolderListScreen extends StatefulWidget {
//   final List<String> folders;
//   final String title;
//
//   const FullFolderListScreen({required this.folders, required this.title});
//
//   @override
//   _FullFolderListScreenState createState() => _FullFolderListScreenState();
// }
//
// class _FullFolderListScreenState extends State<FullFolderListScreen> {
//   List<String> folders;
//
//   _FullFolderListScreenState() : folders = [];
//
//   @override
//   void initState() {
//     super.initState();
//     folders = widget.folders;
//   }
//
//   void _renameFolder(BuildContext context, int index) {
//     final TextEditingController _folderNameController =
//         TextEditingController(text: folders[index]);
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('폴더 이름 바꾸기'),
//           content: TextField(
//             controller: _folderNameController,
//             decoration: InputDecoration(hintText: '폴더 이름'),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('취소', style: TextStyle(color: Colors.red)),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text('저장'),
//               onPressed: () {
//                 setState(() {
//                   folders[index] = _folderNameController.text;
//                 });
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _deleteFolder(BuildContext context, int index) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('폴더 삭제하기'),
//           content: Text('정말로 삭제하시겠습니까?'),
//           actions: <Widget>[
//             TextButton(
//               child: Text('취소', style: TextStyle(color: Colors.red)),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text('삭제'),
//               onPressed: () {
//                 setState(() {
//                   folders.removeAt(index);
//                 });
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return SingleChildScrollView(
//             child: Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: folders.asMap().entries.map((entry) {
//                   int index = entry.key;
//                   String folder = entry.value;
//                   return GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               FolderFilesScreen(folderName: folder),
//                         ),
//                       );
//                     },
//                     child: FolderListItem(
//                       folder: folder,
//                       onRename: () => _renameFolder(context, index),
//                       onDelete: () => _deleteFolder(context, index),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class FolderListItem extends StatelessWidget {
//   final String folder;
//   final VoidCallback onRename;
//   final VoidCallback onDelete;
//
//   const FolderListItem(
//       {required this.folder, required this.onRename, required this.onDelete});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 15),
//       padding: EdgeInsets.all(12),
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.green.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 25,
//             height: 25,
//             decoration: BoxDecoration(
//               color: Colors.green.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Icon(Icons.folder_sharp, size: 22),
//             ),
//           ),
//           SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               folder,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           Row(
//             children: [
//               Text(
//                 '0 files',
//                 style: TextStyle(
//                   color: Color(0xFF005A38),
//                   fontSize: 12,
//                   fontFamily: 'DM Sans',
//                   fontWeight: FontWeight.w500,
//                   height: 1.5,
//                 ),
//               ),
//               SizedBox(width: 10),
//               RenameDeletePopup(
//                 onRename: onRename,
//                 onDelete: onDelete,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
