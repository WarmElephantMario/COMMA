import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'components.dart';
import 'package:provider/provider.dart';
import 'model/user_provider.dart';
import 'api/api.dart';
import '17_allFilesPage.dart';
import 'package:http/http.dart' as http;
import '63record.dart';
import '66colon.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '12_hompage_search.dart';
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

  // 강의 파일 클릭 이벤트에서 폴더 이름 조회
  void fetchFolderAndNavigate(BuildContext context, int folderId,
      String fileType, Map<String, dynamic> file) async {
    try {
      final response = await http.get(
          Uri.parse('${API.baseUrl}/api/getFolderName/$fileType/$folderId'));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String folderName = data['folder_name']?.toString() ?? 'Unknown Folder';
        navigateToPage(context, folderName, file, fileType);
      } else {
        print('Failed to load folder name: ${response.statusCode}');
        navigateToPage(context, 'Unknown Folder', file, fileType);
      }
    } catch (e) {
      print('Error fetching folder name: $e');
      // 오류 발생 시 navigateToPage를 다시 호출하지 않음
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
        );
      }

      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    } catch (e) {
      print('Error in navigateToPage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    final userProvider = Provider.of<UserProvider>(context);
    return PopScope(
    canPop: false,
    child:  Scaffold(
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
                            text: userProvider.user?.user_nickname ?? 'Guest',
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
                            userKey: userProvider.user!.userKey,
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
                            userKey: userProvider.user!.userKey,
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
                              await fetchOtherFolders('colon', file['folder_id']);
                              showQuickMenu(
                                context,
                                file['id'],
                                'colon',
                                file['folder_id'],
                                moveItem,
                                () => fetchOtherFolders('colon', file['folder_id']),
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
