import 'package:flutter/material.dart';

class RenameDeletePopup extends StatelessWidget {
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const RenameDeletePopup({
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'rename') {
          onRename();
        } else if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'rename',
          child: Text('이름 바꾸기'),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('삭제하기'),
        ),
      ],
    );
  }
}
