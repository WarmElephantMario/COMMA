import 'package:flutter/material.dart';
import 'api/api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '63record.dart';
import '66colon.dart';
import 'components.dart'; // showCustomMenu 함수가 있는 파일을 import

class AllFilesPage extends StatefulWidget {
  final int userKey;
  final String fileType;

  const AllFilesPage({
    super.key,
    required this.userKey,
    required this.fileType,
  });

  @override
  _AllFilesPageState createState() => _AllFilesPageState();
}

class _AllFilesPageState extends State<AllFilesPage> {
  List<Map<String, dynamic>> files = [];

  @override
  void initState() {
    super.initState();
    fetchFiles();
  }

  Future<void> fetchFiles() async {
    final response = await http.get(Uri.parse(
        '${API.baseUrl}/api/get${widget.fileType == 'lecture' ? 'Lecture' : 'Colon'}Files/${widget.userKey}'));

    if (response.statusCode == 200) {
      setState(() {
        files =
            List<Map<String, dynamic>>.from(jsonDecode(response.body)['files']);
      });
    } else {
      throw Exception('Failed to load files');
    }
  }

  String formatDateTimeToKorean(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return 'Unknown';
    final DateTime utcDateTime = DateTime.parse(dateTime);
    final DateTime koreanDateTime = utcDateTime.add(const Duration(hours: 9));
    return DateFormat('yyyy/MM/dd HH:mm').format(koreanDateTime);
  }

  // 강의 파일 클릭 이벤트에서 폴더 이름 조회
  void fetchFolderAndNavigate(BuildContext context, int folderId,
      String fileType, Map<String, dynamic> file) async {
    try {
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
    } catch (e) {
      print('Error fetching folder name: $e');
      navigateToPage(context, 'Unknown Folder', file, fileType);
    }
  }

  // 강의 파일 또는 콜론 파일 페이지로 네비게이션
  void navigateToPage(BuildContext context, String folderName,
      Map<String, dynamic> file, String fileType) {
    Widget page = fileType == 'lecture'
        ? RecordPage(
            lecturefileId: file['id'],
            selectedFolderId: file['folder_id'].toString(),
            noteName: file['file_name'] ?? 'Unknown Note',
            fileUrl:
                file['file_url'] ?? 'https://defaulturl.com/defaultfile.txt',
            folderName: folderName,
            recordingState: RecordingState.recorded,
            lectureName: file['lecture_name'] ?? 'Unknown Lecture',
            responseUrl: 'https://defaulturl.com/defaultfile.txt', //수정 필요
            type: 1, //수정 필요
          )
        : ColonPage(
            folderName: folderName,
            noteName: file['file_name'] ?? 'Unknown Note',
            lectureName: file['lecture_name'] ?? 'Unknown Lecture',
            createdAt: file['created_at'] ?? 'Unknown Date',
          );

    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 48, 48, 48)),
        title: Text(
          widget.fileType == 'lecture' ? '전체 강의 파일' : '전체 콜론 파일',
          style: const TextStyle(
              color: Color.fromARGB(255, 48, 48, 48),
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
      ),
      body: files.isEmpty
          ? const Center(child: Text('파일이 없습니다.'))
          : ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];

                // null 값을 처리하여 기본값을 설정
                final fileName = file['file_name'] ?? 'Unknown Note';
                final fileUrl = file['file_url'] ??
                    'https://defaulturl.com/defaultfile.txt';
                final lectureName = file['lecture_name'] ?? 'Unknown Lecture';
                final createdAt = file['created_at'] ?? 'Unknown Date';
                final folderId = file['folder_id'] ?? 0;
                final fileType = widget.fileType;

                return GestureDetector(
                  onTap: () {
                    print('File $fileName is clicked');
                    fetchFolderAndNavigate(
                        context, folderId, fileType, file); // 파일을 탭하면 열기
                  },
                  child: LectureExample(
                    lectureName: fileName,
                    date: formatDateTimeToKorean(createdAt),
                    onRename: () {
                      // 이름 변경 동작 추가
                      showRenameDialog(
                        context,
                        index,
                        files,
                        (id, newName) {
                          // 이름 변경 로직 추가
                          // API 호출하여 이름 변경
                          print('Rename file with ID $id to $newName');
                        },
                        setState,
                        '파일 이름 바꾸기',
                        'file_name',
                      );
                    },
                    onDelete: () {
                      // 삭제 동작 추가
                      showConfirmationDialog(
                        context,
                        '정말 파일을 삭제하시겠습니까?',
                        '파일을 삭제하면 다시 복구할 수 없습니다.',
                        () {
                          // API 호출하여 파일 삭제
                          print('Delete file with ID ${file['id']}');
                          setState(() {
                            files.removeAt(index);
                          });
                        },
                      );
                    },
                    onMove: () {
                      // 이동 동작 추가
                      print('Move file with ID ${file['id']}');
                      // API 호출하여 파일 이동
                    },
                  ),
                );
              },
            ),
    );
  }
}
