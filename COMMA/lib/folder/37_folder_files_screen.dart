import 'package:flutter/material.dart';
import 'package:flutter_plugin/16_homepage_move.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_plugin/components.dart';
import 'package:flutter_plugin/66colon.dart'; // ColonPage import
import 'package:flutter_plugin/63record.dart'; // RecordPage import
import 'package:provider/provider.dart';
import '../model/user_provider.dart';
import '../api/api.dart';
import 'package:flutter_plugin/62lecture_start.dart';
import 'package:flutter_plugin/63record.dart';
import '../mypage/43_font_size_page.dart';


class FolderFilesScreen extends StatefulWidget {
  final String folderName;
  final int? folderId;
  final String folderType;

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
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchFiles();
  }

  Future<void> fetchFiles() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userKey = userProvider.user?.userKey;
    final disType = userProvider.user?.dis_type; // dis_type 값 가져오기

    if (userKey != null) {
      final response = await http.get(Uri.parse(
        '${API.baseUrl}/api/${widget.folderType}-files/${widget.folderId}?userKey=$userKey',
      ));

      if (response.statusCode == 200) {
        final List<dynamic> fileData = jsonDecode(response.body);
        setState(() {
          files = fileData.map((file) {
            return {
              'file_name': file['file_name'] ?? 'Unknown',
              'file_url': file['file_url'] ?? '',
              'created_at': file['created_at'] ?? '',
              'id': file['id'], // 파일 ID 추가
              'folder_id': file['folder_id'] ?? 0, // 폴더 ID 추가
              'lecture_name':
                  file['lecture_name'] ?? 'Unknown Lecture', // 강의 이름 추가
              // 'alternative_text_url':file['alternative_text_url']?? ''
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
    final userKey = userProvider.user?.userKey;

    if (userKey != null) {
      final url =
          Uri.parse('${API.baseUrl}/api/${widget.folderType}-files/$id');
      try {
        final response = await http.put(url,
            body: jsonEncode({'file_name': newName, 'userKey': userKey}),
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
    final userKey = userProvider.user?.userKey;

    if (userKey != null) {
      final url =
          Uri.parse('${API.baseUrl}/api/${widget.folderType}-files/$id');
      try {
        final response = await http.delete(url,
            body: jsonEncode({'userKey': userKey}),
            headers: {'Content-Type': 'application/json'});
        if (response.statusCode != 200) {
          throw Exception('Failed to delete file');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  String formatDateTime(String dateTime) {
    if (dateTime.isEmpty) return 'Unknown';
    final DateTime parsedDateTime = DateTime.parse(dateTime);
    return DateFormat('yyyy/MM/dd HH:mm').format(parsedDateTime);
  }

  Future<List<String>> fetchKeywords(int lecturefileId) async {
    try {
      final response = await http
          .get(Uri.parse('${API.baseUrl}/api/getKeywords/$lecturefileId'));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final String keywordsUrl = responseData['keywordsUrl'];

          return await fetchKeywordsFromUrl(keywordsUrl);
        } else {
          print('Error fetching keywords: ${responseData['error']}');
          return [];
        }
      } else {
        print('Failed to fetch keywords with status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<String>> fetchKeywordsFromUrl(String keywordsUrl) async {
    try {
      final response = await http.get(Uri.parse(keywordsUrl));

      if (response.statusCode == 200) {
        final String content = utf8.decode(response.bodyBytes);
        return content.split(',');
      } else {
        print('Failed to fetch keywords from URL');
        return [];
      }
    } catch (e) {
      print('Error fetching keywords from URL: $e');
      return [];
    }
  }

  void fetchFolderAndNavigate(BuildContext context, int folderId,
      String fileType, Map<String, dynamic> file) async {
    try {
      final lectureFileId = file['id'];
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userDisType = userProvider.user?.dis_type;

      final existLectureResponse = await http.get(
          Uri.parse('${API.baseUrl}/api/checkExistLecture/$lectureFileId'));

      if (existLectureResponse.statusCode == 200) {
        var existLectureData = jsonDecode(existLectureResponse.body);

        if (existLectureData['existLecture'] == 0) {
          List<String> keywords = await fetchKeywords(lectureFileId);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LectureStartPage(
                lectureFolderId: file['folder_id'],
                lecturefileId: file['id'],
                lectureName: file['lecture_name'] ?? 'Unknown Lecture',
                fileURL: file['file_url'] ??
                    'https://defaulturl.com/defaultfile.txt',
                type: userDisType!,
                selectedFolder: widget.folderName,
                noteName: file['file_name'] ?? 'Unknown Note',
                responseUrl: file['alternative_text_url'] ??
                    'https://defaulturl.com/defaultfile.txt',
                keywords: keywords,
              ),
            ),
          );
        } else if (existLectureData['existLecture'] == 1) {
          final response = await http.get(Uri.parse(
              '${API.baseUrl}/api/getFolderName/$fileType/$folderId'));
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            navigateToPage(context, data['folder_name'] ?? 'Unknown Folder',
                file, fileType);
          } else {
            print('Failed to load folder name: ${response.statusCode}');
            navigateToPage(context, 'Unknown Folder', file, fileType);
          }
        }
      } else {
        print(
            'Failed to check existLecture: ${existLectureResponse.statusCode}');
      }
    } catch (e) {
      print('Error fetching folder name or existLecture: $e');
      navigateToPage(context, 'Unknown Folder', file, fileType);
    }
  }

  void navigateToPage(BuildContext context, String folderName,
      Map<String, dynamic> file, String fileType) {
    Widget page = fileType == 'lecture'
        ? RecordPage(
            lectureFolderId: file['folder_id'],
            noteName: file['file_name'] ?? 'Unknown Note',
            fileUrl:
                file['file_url'] ?? 'https://defaulturl.com/defaultfile.txt',
            folderName: folderName,
            recordingState: RecordingState.recorded,
            lectureName: file['lecture_name'] ?? 'Unknown Lecture',
            responseUrl: 'https://defaulturl.com/defaultfile.txt',
            type: 0,
            lecturefileId: file['id'],
          )
        : ColonPage(
            folderName: folderName,
            noteName: file['file_name'] ?? 'Unknown Note',
            lectureName: file['lecture_name'] ?? 'Unknown Lecture',
            createdAt: file['created_at'] ?? 'Unknown Date',
            fileUrl: file['file_url'] ?? 'Unknown fileUrl',
            colonFileId: file['id'] ?? 'Unknown id',
            folderId: file['folder_id'] ?? 'Unknown folderId',
          );

    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainPage()),
            );
          });
        }
      },
        child : Scaffold(

      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text(
            widget.folderName,
            style: TextStyle(
                color: theme.colorScheme.onTertiary,
                fontWeight: FontWeight.w600),
          ),
          iconTheme: IconThemeData(color: theme.colorScheme.onTertiary)),
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
                  return GestureDetector(
                    onTap: () => fetchFolderAndNavigate(
                        context, file['folder_id'], widget.folderType, file),
                    child: FileListItem(
                      file: file,
                      onRename: () => showRenameDialog(
                          context,
                          index,
                          files,
                          (id, newName) => _renameFile(id, newName),
                          setState,
                          "파일 이름 바꾸기",
                          "file_name"),
                      onDelete: () => showConfirmationDialog(
                          context,
                          "정말 파일을 삭제하시겠습니까?",
                          "파일을 삭제하면 다시 복구할 수 없습니다.", () async {
                        await _deleteFile(file['id']);
                        setState(() {
                          files.removeAt(index);
                        });
                      }),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar:
          buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
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

  String formatDateTimeToKorean(String dateTime) {
    if (dateTime.isEmpty) return 'Unknown';
    final DateTime utcDateTime = DateTime.parse(dateTime);
    final DateTime koreanDateTime = utcDateTime.add(const Duration(hours: 9));
    return DateFormat('yyyy/MM/dd HH:mm').format(koreanDateTime);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryFixed,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSecondary,
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
              color: theme.colorScheme.surfaceBright,
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file['file_name'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 16 ,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onTertiary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5),
                Text(
                  formatDateTimeToKorean(file['created_at'] ?? ''),
                  style: TextStyle(
                    fontSize: 12 ,
                    color: theme.colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            child: ImageIcon(
              AssetImage('assets/folder_menu.png'),
              color: Color(0xFFFFA17A),
            ),
            onTap: () {
              showCustomMenu2(context, onRename, onDelete);
            },
          ),
        ],
      ),
    );
  }
}
