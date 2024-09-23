import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'components.dart';
import 'package:provider/provider.dart';
import 'model/user_provider.dart';
import 'api/api.dart';
import '17_allFilesPage.dart';
import 'package:http/http.dart' as http;
import '62lecture_start.dart';
import '63record.dart';
import '66colon.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '12_hompage_search.dart';
import '../model/44_font_size_provider.dart';

// import 'popscope.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Map<String, dynamic>> lectureFiles = [];
  List<Map<String, dynamic>> colonFiles = [];
  List<Map<String, dynamic>> folderList = [];
  int _selectedIndex = 0;

  final FocusNode _focusNode = FocusNode(); // FocusNode 추가

  @override
  void initState() {
    super.initState();
    fetchLectureFiles();
    fetchColonFiles();

    // 화면이 빌드된 후 초점을 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

Future<void> fetchLectureFiles() async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userKey = userProvider.user?.userKey;
  final disType = userProvider.user?.dis_type; // dis_type 값 가져오기

  if (userKey != null && disType != null) {
    try {
      print('Fetching lecture files for userKey: $userKey and disType: $disType');
      
      final response = await http.get(Uri.parse(
        '${API.baseUrl}/api/getLectureFiles/$userKey?disType=$disType', // dis_type 파라미터 추가
      ));

      print('Response status code: ${response.statusCode}'); // 상태 코드 로그

      if (response.statusCode == 200) {
        print('Lecture files fetched successfully'); // 성공 로그
        final List<Map<String, dynamic>> fileData = List<Map<String, dynamic>>.from(
          jsonDecode(response.body)['files']
        );
        setState(() {
          lectureFiles = fileData;
        });
      } else {
        print('Failed to load lecture files. Status code: ${response.statusCode}');
        print('Response body: ${response.body}'); // 응답 본문 로그
        throw Exception('Failed to load lecture files');
      }
    } catch (e, stacktrace) {
      print('Error occurred while fetching lecture files: $e');
      print('Stacktrace: $stacktrace'); // 스택 트레이스 로그
      throw Exception('Failed to fetch lecture files: $e');
    }
  } else {
    print('UserKey or disType is null');
  }
}



Future<void> fetchColonFiles() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userKey = userProvider.user?.userKey;
    final disType = userProvider.user?.dis_type; // dis_type 값 가져오기

    if (userKey != null && disType != null) {
      final response = await http.get(Uri.parse(
        '${API.baseUrl}/api/getColonFiles/$userKey?disType=$disType', // dis_type 파라미터 추가
      ));

      if (response.statusCode == 200) {
        setState(() {
          colonFiles =
              List<Map<String, dynamic>>.from(jsonDecode(response.body)['files']);
        });
      } else {
        throw Exception('Failed to load colon files');
      }
    }
  }


  Future<void> fetchOtherFolders(String fileType, int currentFolderId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userKey = userProvider.user?.userKey;

    if (userKey != null) {
      try {
        final uri = Uri.parse(
            '${API.baseUrl}/api/getOtherFolders/$fileType/$userKey=$userKey');
        final response = await http.get(uri);

        if (response.statusCode == 200) {
          List<Map<String, dynamic>> fetchedFolders =
              List<Map<String, dynamic>>.from(jsonDecode(response.body));

          setState(() {
            folderList = fetchedFolders.map((folder) {
              return {
                ...folder,
                'selected': false,
              };
            }).toList();
            print('Fetched folders in fetchOtherFolders: $folderList');
          });
        } else {
          throw Exception(
              'Failed to load folders with status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching other folders: $e');
        rethrow;
      }
    } else {
      print('User Key is null, cannot fetch folders.');
    }
  }

  void showQuickMenu(
    BuildContext context,
    int fileId,
    String fileType,
    int currentFolderId,
    Future<void> Function(int, int, String) moveItem,
    Future<void> Function() fetchOtherFolders,
    List<Map<String, dynamic>> folders,
    Function(int) selectFolder,
  ) async {
    print('Attempting to fetch other folders.');
    try {
      await fetchOtherFolders();
      print('Fetched other folders successfully.');
    } catch (e) {
      print('Error fetching other folders: $e');
    }

    var updatedFolders = folders.map((folder) {
      bool isSelected = folder['id'] == currentFolderId;
      return {
        ...folder,
        'selected': isSelected,
      };
    }).toList();

    print('Updated folders: $updatedFolders');

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: Color.fromRGBO(84, 84, 84, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text(
                        '다음으로 이동',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final selectedFolder = updatedFolders.firstWhere(
                            (folder) => folder['selected'] == true,
                            orElse: () => {'id': null},
                          );
                          final selectedFolderId = selectedFolder['id'];
                          await moveItem(fileId, selectedFolderId, fileType);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          '이동',
                          style: TextStyle(
                            color: Color.fromRGBO(255, 161, 122, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Center(
                    child: Text(
                      '현재 위치 외 다른 폴더로 이동할 수 있어요.',
                      style: TextStyle(
                        color: Color(0xFF575757),
                        fontSize: 13,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: updatedFolders.map((folder) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: CustomRadioButton3(
                            label: folder['folder_name'],
                            isSelected: folder['selected'],
                            onChanged: (bool value) {
                              setState(() {
                                for (var f in updatedFolders) {
                                  f['selected'] = false;
                                }
                                folder['selected'] = value;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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


 // 강의 파일 클릭 이벤트에서 폴더 이름 조회 및 existLecture 확인
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
        final response = await http.get(
            Uri.parse('${API.baseUrl}/api/getFolderName/$fileType/$folderId'));
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LectureStartPage(
                lectureFolderId: file['folder_id'],
                lecturefileId: file['id'],
                lectureName: file['lecture_name'] ?? 'Unknown Lecture',
                fileURL: file['file_url'] ?? 'https://defaulturl.com/defaultfile.txt',
                type: userDisType!, // 수정
                selectedFolder: data['folder_name'], // 폴더 이름
                noteName: file['file_name'] ?? 'Unknown Note',
                responseUrl: file['alternative_text_url'] ?? 'https://defaulturl.com/defaultfile.txt', // null 또는 실제 값
                keywords: keywords, // 키워드 목록
              ),
            ),
          );
        }
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
    try {
      Widget page;

      int lectureFolderId;
      int colonFileId;

      // folder_id가 문자열일 경우 int로 변환

      lectureFolderId = file['folder_id'];

      // id가 문자열일 경우 int로 변환

      colonFileId = file['id'];

      //print('Navigating to page with folderName: $folderName, lectureFolderId: $lectureFolderId, colonFileId: $colonFileId');

      if (fileType == 'lecture') {
        if (file['type'] == 0) {
          // 강의 파일 + 대체텍스트인 경우
          page = RecordPage(
            lecturefileId: file['id'] ?? 'Unknown id',
            lectureFolderId: lectureFolderId,
            noteName: file['file_name'] ?? 'Unknown Note',
            fileUrl:
                file['file_url'] ?? 'https://defaulturl.com/defaultfile.txt',
            folderName: folderName,
            recordingState: RecordingState.recorded,
            lectureName: file['lecture_name'] ?? 'Unknown Lecture',
            responseUrl: file['alternative_text_url'] ??
                'https://defaulturl.com/defaultfile.txt',
            type: file['type'] ?? 'Unknown Type',
          );
        } else {
          // 강의 파일 + 실시간 자막인 경우
          page = RecordPage(
            lecturefileId: file['id'] ?? 'Unknown id',
            lectureFolderId: lectureFolderId,
            noteName: file['file_name'] ?? 'Unknown Note',
            fileUrl:
                file['file_url'] ?? 'https://defaulturl.com/defaultfile.txt',
            folderName: folderName,
            recordingState: RecordingState.recorded,
            lectureName: file['lecture_name'] ?? 'Unknown Lecture',
            type: file['type'] ?? 'Unknown Type',
          );
        }
      } else {
        // 콜론 파일인 경우
        page = ColonPage(
          folderName: folderName,
          noteName: file['file_name'] ?? 'Unknown Note',
          lectureName: file['lecture_name'] ?? 'Unknown Lecture',
          createdAt: file['created_at'] ?? 'Unknown Date',
          fileUrl: file['file_url'] ?? 'Unknown fileUrl',
          colonFileId: colonFileId,
          folderId: file['folder_id'] ?? 'Unknown folderId',
        );
      }

      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    } catch (e) {
      print('Error in navigateToPage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 폰트 크기 비율을 Provider에서 가져옴
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    // 디스플레이 비율을 가져옴
    final scaleFactor = fontSizeProvider.scaleFactor;
    // final size = MediaQuery.of(context).size;
    final userProvider = Provider.of<UserProvider>(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(
            color: Color(0xFF36AE92),
          ),
          leading: null,
          actions: [
            Semantics(
              label: '검색 아이콘',
              child: IconButton(
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
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Focus(
                  // FocusNode를 사용하여 초점을 받을 수 있도록 설정
                  focusNode: _focusNode,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                             TextSpan(
                              text: '안녕하세요, ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24* scaleFactor,
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                            TextSpan(
                              text: userProvider.user?.user_nickname ?? 'Guest',
                              style:  TextStyle(
                                color: Color(0xFF36AE92), // 원하는 색상으로 설정
                                fontSize: 24* scaleFactor,
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w700,
                                height: 1.5,
                              ),
                            ),
                             TextSpan(
                              text: ' 님',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24* scaleFactor,
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      '최근에 학습한 강의 파일이에요.',
                      style: TextStyle(
                        color: Color(0xFF575757),
                        fontSize: 13* scaleFactor,
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
                              userKey: userProvider.user!.userKey,
                              fileType: 'lecture',
                            ),
                          ),
                        );
                      },
                      child:  Row(
                        children: [
                          Text(
                            '전체 보기',
                            style: TextStyle(
                              color: Color(0xFF36AE92),
                              fontSize: 12* scaleFactor,
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
                         Text(
                          '최근에 학습한 강의 자료가 없어요.',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13* scaleFactor,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                          ),
                        )
                      ]
                    : lectureFiles.take(3).map((file) {
                        return Semantics(
                          sortKey: OrdinalSortKey(2),
                          child: GestureDetector(
                            onTap: () {
                              print(
                                  'Lecture ${file['file_name'] ?? "N/A"} is clicked');
                              print('File details: $file');
                              fetchFolderAndNavigate(
                                  context, file['folder_id'], 'lecture', file);
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
                                  folderList,
                                  (selectedFolder) {
                                    setState(() {
                                      file['folder_id'] = selectedFolder;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      }).toList()),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      '최근에 학습한 콜론 파일이에요.',
                      style: TextStyle(
                        color: Color(0xFF575757),
                        fontSize: 13* scaleFactor,
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
                              userKey: userProvider.user!.userKey,
                              fileType: 'colon',
                            ),
                          ),
                        );
                      },
                      child:  Row(
                        children: [
                          Text(
                            '전체 보기',
                            style: TextStyle(
                              color: Color(0xFF36AE92),
                              fontSize: 12* scaleFactor,
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
                         Text(
                          '최근에 학습한 콜론 자료가 없어요.',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13* scaleFactor,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                          ),
                        )
                      ]
                    : colonFiles.take(3).map((file) {
                        return Semantics(
                          sortKey: OrdinalSortKey(3),
                          child: GestureDetector(
                            onTap: () {
                              print(
                                  'Colon ${file['file_name'] ?? "N/A"} is clicked');
                              print('Colon file clicked: ${file['file_name']}');
                              print('File details: $file');
                              fetchFolderAndNavigate(
                                  context, file['folder_id'], 'colon', file);
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
                                await fetchOtherFolders(
                                    'colon', file['folder_id']);
                                showQuickMenu(
                                  context,
                                  file['id'],
                                  'colon',
                                  file['folder_id'],
                                  moveItem,
                                  () => fetchOtherFolders(
                                      'colon', file['folder_id']),
                                  folderList,
                                  (selectedFolder) {
                                    setState(() {
                                      file['folder_id'] = selectedFolder;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      }).toList()),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        bottomNavigationBar:
            buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
      ),
    );
  }
}
