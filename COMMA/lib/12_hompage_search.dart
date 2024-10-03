import 'package:flutter/material.dart';
import 'components.dart';
import 'api/api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // 날짜 포맷을 위해 추가
import '63record.dart';
import '66colon.dart';
import 'package:provider/provider.dart';
import 'mypage/44_font_size_page.dart';
import 'model/user_provider.dart';
import '62lecture_start.dart';

class MainToSearchPage extends StatefulWidget {
  const MainToSearchPage({super.key});

  @override
  _MainToSearchPageState createState() => _MainToSearchPageState();
}

class _MainToSearchPageState extends State<MainToSearchPage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> searchResults = [];
  final TextEditingController _searchController = TextEditingController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> searchFiles(String query) async {
    final response = await http
        .get(Uri.parse('${API.baseUrl}/api/searchFiles?query=$query'));

    if (response.statusCode == 200) {
      setState(() {
        searchResults =
            List<Map<String, dynamic>>.from(jsonDecode(response.body)['files']);
      });
    } else {
      print('Failed to search files: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to search files');
    }
  }

  String formatDateTimeToKorean(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return 'Unknown';
    final DateTime utcDateTime = DateTime.parse(dateTime);
    final DateTime koreanDateTime = utcDateTime.add(const Duration(hours: 9));
    return DateFormat('yyyy/MM/dd HH:mm').format(koreanDateTime);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 강의 파일 클릭 이벤트에서 폴더 이름 조회 및 existLecture 확인
void fetchFolderAndNavigate(BuildContext context, int folderId,
    String fileType, Map<String, dynamic> file) async {
  try {
    final lectureFileId = file['id']; // lectureFileId 가져오기
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userDisType = userProvider.user?.dis_type; // 유저의 dis_type 가져오기

    // fileType이 "lecture"일 경우
    if (fileType == "lecture") {
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
          final response = await http.get(Uri.parse(
              '${API.baseUrl}/api/getFolderName/$fileType/$folderId'));
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LectureStartPage(
                  lectureFolderId: file['folder_id'],
                  lecturefileId: file['id'],
                  lectureName: file['lecture_name'] ?? 'Unknown Lecture',
                  fileURL: file['file_url'] ??
                      'https://defaulturl.com/defaultfile.txt',
                  type: userDisType!, // 수정
                  selectedFolder: data['folder_name'], // 폴더 이름
                  noteName: file['file_name'] ?? 'Unknown Note',
                  responseUrl: file['alternative_text_url'] ??
                      'https://defaulturl.com/defaultfile.txt', // null 또는 실제 값
                  keywords: keywords, // 키워드 목록
                ),
              ),
            );
          }
        } else if (existLectureData['existLecture'] == 1) {
          // existLecture가 1이면 기존 페이지로 이동
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
    } 
    // fileType이 "colon"일 경우
    else if (fileType == "colon") {
      // colonFileId 가져오기 (필요한 경우)
      final colonFileId = file['id'];

      // 폴더 이름 가져오기
        // ColonPage로 이동
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
    } else {
      print('The fileType is not "lecture" or "colon". Operation skipped.');
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

  // 데베에서 keywords 가져오기
  Future<List<String>> fetchKeywords(int lecturefileId) async {
    try {
      final response = await http
          .get(Uri.parse('${API.baseUrl}/api/getKeywords/$lecturefileId'));

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


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          title: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: TextField(
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSecondary),
                    controller: _searchController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.colorScheme.primaryFixed,
                      hintText: '검색할 파일명을 입력하세요.',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: Color(0xFF36AE92),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF36AE92),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 75,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    searchFiles(_searchController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF36AE92),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    '검색',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          iconTheme: IconThemeData(color: theme.colorScheme.onSecondary)),
      body: searchResults.isEmpty
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '최근 검색 내역이 없어요.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final file = searchResults[index];
                // null 값을 처리하여 기본값을 설정
                final fileName = file['file_name'] ?? 'Unknown Note';
                final fileUrl = file['file_url'] ??
                    'https://defaulturl.com/defaultfile.txt';
                final lectureName = file['lecture_name'] ?? 'Unknown Lecture';
                final createdAt = file['created_at'] ?? 'Unknown Date';
                final folderId = file['folder_id'] ?? 0;
                final fileType = file['file_type'] ?? 'unknown';

                return ListTile(
                  title: Text(
                    fileName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
                  subtitle: Text(
                    formatDateTimeToKorean(createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
                  onTap: () {
                    print('File $fileName is clicked');
                    fetchFolderAndNavigate(
                        context, folderId, fileType, file); // 파일을 탭하면 열기
                  },
                );
              },
            ),
      bottomNavigationBar:
          buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}
