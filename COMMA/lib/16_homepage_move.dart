import 'package:flutter/material.dart';
import 'package:flutter_plugin/12_homepage_search.dart';
import 'components.dart';
import '14_homepage_search_result.dart';
import 'package:provider/provider.dart';
import 'model/user_provider.dart';
import 'api/api.dart';
import '12_homepage_search.dart';
import 'components.dart';
import '17_allFilesPage.dart';
import 'package:http/http.dart' as http;
import '63record.dart';
import '66colon.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Map<String, dynamic>> lectureFiles = [];
  List<Map<String, dynamic>> colonFiles = [];
  List<Map<String, dynamic>> folders = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchLectureFiles();
    fetchColonFiles();
  }

  Future<void> fetchLectureFiles() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final response = await http.get(Uri.parse(
        '${API.baseUrl}/api/getLectureFiles/${userProvider.user!.userKey}'));

    if (response.statusCode == 200) {
      setState(() {
        lectureFiles =
        List<Map<String, dynamic>>.from(jsonDecode(response.body)['files']);
      });
    } else {
      throw Exception('Failed to load lecture files');
    }
  }

  Future<void> fetchColonFiles() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final response = await http.get(Uri.parse(
        '${API.baseUrl}/api/getColonFiles/${userProvider.user!.userKey}'));

    if (response.statusCode == 200) {
      setState(() {
        colonFiles =
        List<Map<String, dynamic>>.from(jsonDecode(response.body)['files']);
      });
    } else {
      throw Exception('Failed to load colon files');
    }
  }

  Future<void> fetchOtherFolders(String fileType, int currentFolderId) async {
    final response = await http.get(Uri.parse(
        '${API.baseUrl}/api/getOtherFolders/$fileType/$currentFolderId'));

    if (response.statusCode == 200) {
      setState(() {
        folders = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        folders.removeWhere((folder) => folder['id'] == currentFolderId);
        print('Fetched folders: $folders');
      });
    } else {
      throw Exception('Failed to load folders');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      DateTime koreaTime = dateTime.add(const Duration(hours: 9)); // UTC+9로 변환
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(koreaTime);
    } catch (e) {
      print('Error parsing date: $e');
      return dateString; // 오류 발생 시 원래 문자열 반환
    }
  }

  Future<void> renameItem(int fileId, String newName, String fileType) async {
    try {
      final response = await http.put(
        Uri.parse('${API.baseUrl}/api/$fileType-files/$fileId'),
        body: jsonEncode({'file_name': newName}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          if (fileType == 'lecture') {
            lectureFiles = lectureFiles.map((file) {
              if (file['id'] == fileId) {
                return {...file, 'file_name': newName};
              }
              return file;
            }).toList();
          } else {
            colonFiles = colonFiles.map((file) {
              if (file['id'] == fileId) {
                return {...file, 'file_name': newName};
              }
              return file;
            }).toList();
          }
        });
      } else {
        throw Exception('Failed to rename file');
      }
    } catch (error) {
      print('Error renaming file: $error');
      rethrow;
    }
  }

  Future<void> deleteItem(int fileId, String fileType) async {
    try {
      final response = await http.delete(
        Uri.parse('${API.baseUrl}/api/$fileType-files/$fileId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          if (fileType == 'lecture') {
            lectureFiles.removeWhere((file) => file['id'] == fileId);
          } else {
            colonFiles.removeWhere((file) => file['id'] == fileId);
          }
        });
      } else {
        throw Exception('Failed to delete file');
      }
    } catch (error) {
      print('Error deleting file: $error');
      rethrow;
    }
  }

  Future<void> moveItem(int fileId, int newFolderId, String fileType) async {
    try {
      final response = await http.put(
        Uri.parse('${API.baseUrl}/api/$fileType-files/move/$fileId'),
        body: jsonEncode({'folder_id': newFolderId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          if (fileType == 'lecture') {
            lectureFiles = lectureFiles.map((file) {
              if (file['id'] == fileId) {
                return {...file, 'folder_id': newFolderId};
              }
              return file;
            }).toList();
          } else {
            colonFiles = colonFiles.map((file) {
              if (file['id'] == fileId) {
                return {...file, 'folder_id': newFolderId};
              }
              return file;
            }).toList();
          }
        });
      } else {
        throw Exception('Failed to move file');
      }
    } catch (error) {
      print('Error moving file: $error');
      rethrow;
    }
  }
// 강의 파일 클릭 이벤트에서 폴더 이름 조회
  void fetchFolderAndNavigate(BuildContext context, int folderId, String fileType, Map<String, dynamic> file) async {
    try {
      final response = await http.get(Uri.parse('${API.baseUrl}/api/getFolderName/$fileType/$folderId'));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        navigateToPage(context, data['folder_name'] ?? 'Unknown Folder', file, fileType);
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
  void navigateToPage(BuildContext context, String folderName, Map<String, dynamic> file, String fileType) {
    Widget page = fileType == 'lecture' ? RecordPage(
      selectedFolderId: file['folder_id'].toString(),
      noteName: file['file_name'] ?? 'Unknown Note',
      fileUrl: file['file_url'] ?? 'https://defaulturl.com/defaultfile.txt',
      folderName: folderName,
      recordingState: RecordingState.recorded,
      lectureName: file['lecture_name'] ?? 'Unknown Lecture',
    ) : ColonPage(
      folderName: folderName,
      noteName: file['file_name'] ?? 'Unknown Note',
      lectureName: file['lecture_name'] ?? 'Unknown Lecture',
      createdAt: file['created_at'] ?? 'Unknown Date',
    );

    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }




  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        iconTheme: const IconThemeData(
          color: Color(0xFF36AE92),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search_rounded,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainToSearchPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: '안녕하세요, ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    TextSpan(
                      text: '${userProvider.user?.user_nickname ?? 'Guest'}',
                      style: const TextStyle(
                        color: Color(0xFF36AE92), // 원하는 색상으로 설정
                        fontSize: 24,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                    const TextSpan(
                      text: ' 님',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '최근에 학습한 강의 파일이에요.',
                    style: TextStyle(
                      color: Color(0xFF575757),
                      fontSize: 13,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllFilesPage(
                            userId: userProvider.user!.userKey,
                            fileType: 'lecture',
                          ),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Text(
                          '전체 보기',
                          style: TextStyle(
                            color: Color(0xFF36AE92),
                            fontSize: 12,
                            fontFamily: 'Mulish',
                            fontWeight: FontWeight.w800,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: Color(0xFF36AE92),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...(lectureFiles.isEmpty
                  ? [
                const Text(
                  '최근에 학습한 강의 자료가 없어요.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                )
              ]
                  : lectureFiles.take(3).map((file) {
                return GestureDetector(
                  onTap: () {
                    print('Lecture ${file['file_name'] ?? "N/A"} is clicked');
                    print('File details: $file');
                    fetchFolderAndNavigate(context, file['folder_id'],'lecture', file);

                  },
                  child: LectureExample(
                    lectureName: file['file_name'] ?? 'Unknown',
                    date: formatDate(file['created_at'] ?? 'Unknown'),
                    onRename: () => showRenameDialog(
                      context,
                      lectureFiles.indexOf(file),
                      lectureFiles,
                          (id, name) => renameItem(id, name, 'lecture'),
                      setState,
                      '이름 바꾸기',
                      'file_name',
                    ),
                    onDelete: () async {
                      await deleteItem(file['id'], 'lecture');
                      setState(() {
                        lectureFiles.remove(file);
                      });
                    },
                    onMove: () async {
                      await fetchOtherFolders(
                          'lecture', file['folder_id']);
                      showQuickMenu(
                        context,
                        file['id'],
                        'lecture',
                        file['folder_id'],
                        moveItem,
                            () => fetchOtherFolders(
                            'lecture', file['folder_id']),
                        folders,
                        setState,
                      );
                    },
                  ),
                );
              }).toList()),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '최근에 학습한 콜론 파일이에요.',
                    style: TextStyle(
                      color: Color(0xFF575757),
                      fontSize: 13,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllFilesPage(
                            userId: userProvider.user!.userKey,
                            fileType: 'colon',
                          ),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Text(
                          '전체 보기',
                          style: TextStyle(
                            color: Color(0xFF36AE92),
                            fontSize: 12,
                            fontFamily: 'Mulish',
                            fontWeight: FontWeight.w800,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: Color(0xFF36AE92),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...(colonFiles.isEmpty
                  ? [
                const Text(
                  '최근에 학습한 콜론 자료가 없어요.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                )
              ]
                  : colonFiles.take(3).map((file) {
                return GestureDetector(
                  onTap: () {
                    print('Colon ${file['file_name'] ?? "N/A"} is clicked');
                    print('Colon file clicked: ${file['file_name']}');
                    print('File details: $file');
                    fetchFolderAndNavigate(context, file['folder_id'],'colon', file);
                  },
                  child: LectureExample(
                    lectureName: file['file_name'] ?? 'Unknown',
                    date: formatDate(file['created_at'] ?? 'Unknown'),
                    onRename: () => showRenameDialog(
                      context,
                      colonFiles.indexOf(file),
                      colonFiles,
                          (id, name) => renameItem(id, name, 'colon'),
                      setState,
                      '이름 바꾸기',
                      'file_name',
                    ),
                    onDelete: () async {
                      await deleteItem(file['id'], 'colon');
                      setState(() {
                        colonFiles.remove(file);
                      });
                    },
                    onMove: () async {
                      await fetchOtherFolders('colon', file['folder_id']);
                      showQuickMenu(
                        context,
                        file['id'],
                        'colon',
                        file['folder_id'],
                        moveItem,
                            () =>
                            fetchOtherFolders('colon', file['folder_id']),
                        folders,
                        setState,
                      );
                    },
                  ),
                );
              }).toList()),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar:buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}