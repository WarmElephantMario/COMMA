import 'package:flutter/material.dart';
import 'package:flutter_plugin/components.dart';

class FolderList extends StatelessWidget {
  final List<Map<String, dynamic>> folders;
  final Function(Map<String, dynamic>) onFolderTap;
  final Function(int) onRename;
  final Function(int) onDelete;

  const FolderList({
    super.key,
    required this.folders,
    required this.onFolderTap,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: folders.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> folder = entry.value;
        return GestureDetector(
          onTap: () => onFolderTap(folder),
          child: FolderListItem(
            folder: folder,
            onRename: () => onRename(index),
            onDelete: () => onDelete(index),
          ),
        );
      }).toList(),
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
