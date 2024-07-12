import 'package:flutter/material.dart';
import 'components.dart';
import 'api/api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // 날짜 포맷을 위해 추가
import '63record.dart';
import '66colon.dart';

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
            selectedFolderId: file['folder_id'].toString(),
            noteName: file['file_name'] ?? 'Unknown Note',
            fileUrl:
                file['file_url'] ?? 'https://defaulturl.com/defaultfile.txt',
            folderName: folderName,
            recordingState: RecordingState.recorded,
            lectureName: file['lecture_name'] ?? 'Unknown Lecture',
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
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: TextField(
                    style: TextStyle(color: Colors.grey[800]),
                    controller: _searchController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromRGBO(228, 240, 231, 100),
                      hintText: '검색할 파일명을 입력하세요.',
                      hintStyle: const TextStyle(
                        color: Color(0xFF36AE92),
                        fontSize: 15,
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
                    // iconColor: const Color(0xFF36AE92), // 검색 버튼 색상
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '검색',
                    style: TextStyle(color: Colors.white, fontSize: 14.5),
                  ),
                ),
              ),
            ],
          ),
          iconTheme:
              const IconThemeData(color: Color.fromARGB(255, 48, 48, 48))),
      body: searchResults.isEmpty
          ? const SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(50.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '최근 검색 내역이 없어요.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w700,
                          height: 1.5,
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
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                  subtitle: Text(
                    formatDateTimeToKorean(createdAt),
                    style: TextStyle(color: Colors.grey[700]),
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
