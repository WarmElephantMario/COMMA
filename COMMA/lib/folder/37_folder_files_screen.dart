import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_plugin/components.dart';
import 'package:flutter_plugin/66colon.dart'; // ColonPage import
import 'package:flutter_plugin/63record.dart'; // RecordPage import
import 'package:provider/provider.dart';
import '../model/user_provider.dart';
import '../api/api.dart';
import 'package:flutter_plugin/62lecture_start.dart';

import 'package:provider/provider.dart';


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
                  file['lecture_name'] ?? 'Unknown Lecture' ,// 강의 이름 추가
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

// 데베에서 keywords 가져오기
Future<List<String>> fetchKeywords(int lecturefileId) async {
  try {
    final response = await http.get(Uri.parse('${API.baseUrl}/api/getKeywords/$lecturefileId'));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        final String keywordsUrl = responseData['keywordsUrl'];

        // keywords_url에서 키워드 리스트를 가져옴
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

// keywords_url에서 키워드 리스트를 가져오는 함수
Future<List<String>> fetchKeywordsFromUrl(String keywordsUrl) async {
  try {
    final response = await http.get(Uri.parse(keywordsUrl));

    if (response.statusCode == 200) {
      // UTF-8로 디코딩 처리
      final String content = utf8.decode(response.bodyBytes);
      return content.split(','); // ,로 분리하여 키워드 리스트 반환
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
    final lectureFileId = file['id']; // lectureFileId 가져오기
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userDisType = userProvider.user?.dis_type; // 유저의 dis_type 가져오기

    // 1. 먼저 lecturefileId로 existLecture 값을 확인하는 API 요청
    final existLectureResponse = await http.get(
        Uri.parse('${API.baseUrl}/api/checkExistLecture/$lectureFileId'));

    if (existLectureResponse.statusCode == 200) {
      var existLectureData = jsonDecode(existLectureResponse.body);

      // 2. existLecture가 0이면 LectureStartPage로 이동
      if (existLectureData['existLecture'] == 0) {
        // 키워드 fetch 후 LectureStartPage로 이동
        List<String> keywords = await fetchKeywords(lectureFileId);

        // 폴더 이름 가져오기
        // final response = await http.get(
        //     Uri.parse('${API.baseUrl}/api/getFolderName/$fileType/$folderId'));
        // if (response.statusCode == 200) {
        //   var data = jsonDecode(response.body);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LectureStartPage(
                lectureFolderId: file['folder_id'],
                lecturefileId: file['id'],
                lectureName: file['lecture_name'] ?? 'Unknown Lecture',
                fileURL: file['file_url'] ?? 'https://defaulturl.com/defaultfile.txt',
                type: userDisType!, // 수정
                selectedFolder: widget.folderName, // 폴더 이름
                noteName: file['file_name'] ?? 'Unknown Note',
                responseUrl: file['alternative_text_url'] ?? 'https://defaulturl.com/defaultfile.txt', // null 또는 실제 값
                keywords: keywords, // 키워드 목록
              ),
            ),
          );
        // }
      } else if (existLectureData['existLecture'] == 1) {
        // existLecture가 1이면 기존 페이지로 이동
        final response = await http.get(
            Uri.parse('${API.baseUrl}/api/getFolderName/$fileType/$folderId'));
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          navigateToPage(
              context, data['folder_name'] ?? 'Unknown Folder', file, fileType);
        } else {
          print('Failed to load folder name: ${response.statusCode}');
          navigateToPage(context, 'Unknown Folder', file, fileType);
        }
      }
    } else {
      print('Failed to check existLecture: ${existLectureResponse.statusCode}');
    }
  } catch (e) {
    print('Error fetching folder name or existLecture: $e');
    navigateToPage(context, 'Unknown Folder', file, fileType);
  }
}



  // 강의 파일 또는 콜론 파일 페이지로 네비게이션
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
            responseUrl: 'https://defaulturl.com/defaultfile.txt', //수정 필요
            type: 0, //수정 필요
            lecturefileId: file['id'],
          )
        : ColonPage(

            folderName: folderName,
            noteName: file['file_name'] ?? 'Unknown Note',
            lectureName: file['lecture_name'] ?? 'Unknown Lecture',
            createdAt: file['created_at'] ?? 'Unknown Date',
            fileUrl: file['file_url'] ?? 'Unknown fileUrl',
            colonFileId: file['id'] ?? 'Unknown id',
            folderId : file['folder_id'] ?? 'Unknown folderId',
          );

    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            widget.folderName,
            style: const TextStyle(
                color: Color.fromARGB(255, 48, 48, 48),
                fontWeight: FontWeight.w600),
          ),
          iconTheme:
              const IconThemeData(color: Color.fromARGB(255, 48, 48, 48))),
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
                        context,
                        file['folder_id'],
                        widget.folderType,
                        file), // 파일을 탭하면 열기
                    child: FileListItem(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file['file_name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis, // 텍스트 오버플로우 처리
                ),
                const SizedBox(height: 5),
                Text(
                  formatDateTimeToKorean(file['created_at'] ?? ''),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6C7A89),
                  ),
                ),
              ],
            ),
          ),
         GestureDetector(
          child: ImageIcon(
                  AssetImage('assets/folder_menu.png'),
                  color: Color.fromRGBO(255, 161, 122, 1),
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
