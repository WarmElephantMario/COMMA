import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pdfx/pdfx.dart';
import 'dart:typed_data';
import 'components.dart';
import 'api/api.dart';
import 'model/user_provider.dart';
import '62lecture_start.dart';
import '60prepare.dart';

enum RecordingState { initial, recording, recorded }

class RecordPage extends StatefulWidget {
  final String selectedFolderId;
  final String noteName;
  final String fileUrl;
  final String folderName;
  final RecordingState recordingState;
  final String lectureName;

  const RecordPage({
    super.key,
    required this.selectedFolderId,
    required this.noteName,
    required this.fileUrl,
    required this.folderName,
    required this.recordingState,
    required this.lectureName,
  });

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  late RecordingState _recordingState;
  int _selectedIndex = 2;
  dynamic _createdAt;
  bool _isColonFileExists = false;
  bool _isPDF = false;
  late PdfController _pdfController;
  Uint8List? _fileBytes;

  @override
  void initState() {
    super.initState();
    _recordingState = widget.recordingState;
    if (_recordingState == RecordingState.recorded) {
      _fetchCreatedAt();
    }
    _checkColonFile();
    if (_recordingState == RecordingState.initial) {
      _insertInitialData();
    }
    _checkFileType();
  }

  void _checkFileType() {
    final fileName = widget.lectureName.toLowerCase();
    if (fileName.endsWith('.pdf')) {
      setState(() {
        _isPDF = true;
        _loadPdfFile(widget.fileUrl);
      });
    } else if (fileName.endsWith('.png') ||
        fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg')) {
      setState(() {
        _isPDF = false;
      });
    } else {
      setState(() {
        _isPDF = false;
      });
    }
  }

  void _loadPdfFile(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        _fileBytes = response.bodyBytes;
        _pdfController = PdfController(
          document: PdfDocument.openData(_fileBytes!),
        );
      });
    } else {
      print('Failed to load PDF file: ${response.statusCode}');
    }
  }

  Future<void> _insertInitialData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userKey = userProvider.user?.userKey;

    if (userKey != null) {
      var url = '${API.baseUrl}/api/lecture-files';

      var body = {
        'folder_id': widget.selectedFolderId,
        'file_name': widget.noteName,
        'file_url': widget.fileUrl,
        'lecture_name': widget.lectureName,
        'userKey': userKey,
      };

      try {
        var response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          print('File added successfully');
        } else {
          print('Failed to add file: ${response.statusCode}');
        }
      } catch (e) {
        print('Error during HTTP request: $e');
      }
    } else {
      print('User ID is null, cannot insert initial data.');
    }
  }

  Future<void> _fetchCreatedAt() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userKey = userProvider.user?.userKey;

    if (userKey != null) {
      var url = Uri.parse(
          '${API.baseUrl}/api/get-file-created-at?folderId=${widget.selectedFolderId}&fileName=${widget.noteName}');
      try {
        var response = await http.get(url);
        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          setState(() {
            _createdAt = jsonResponse['createdAt'];
          });
        } else {
          print('Failed to fetch created_at: ${response.statusCode}');
        }
      } catch (e) {
        print('Error during HTTP request: $e');
      }
    } else {
      print('User ID is null, cannot fetch created_at.');
    }
  }

  String _formatDate(dynamic dateStr) {
    DateTime dateTime = DateTime.parse(dateStr);
    return DateFormat('yyyy/MM/dd hh:mm a').format(dateTime);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _stopRecording() async {
    setState(() {
      _recordingState = RecordingState.recorded;
    });
    await _fetchCreatedAt();
  }

  Future<void> _startRecording() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userKey = userProvider.user?.userKey;

    if (userKey != null) {
      var url = '${API.baseUrl}/api/lecture-files';

      var body = {
        'folder_id': widget.selectedFolderId,
        'file_name': widget.noteName,
        'file_url': widget.fileUrl,
        'lecture_name': widget.lectureName,
        'userKey': userKey,
      };

      try {
        var response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          print('File added successfully');
        } else {
          print('Failed to add file: ${response.statusCode}');
        }
      } catch (e) {
        print('Error during HTTP request: $e');
      }
    } else {
      print('User ID is null, cannot start recording.');
    }
  }

  Future<bool> _checkColonFileExists(
      String folderName, String noteName, int userKey) async {
    var fetchUrl =
        '${API.baseUrl}/api/check-colon-file?folderName=$folderName&noteName=$noteName&userKey=$userKey';
    try {
      var fetchResponse = await http.get(Uri.parse(fetchUrl));
      if (fetchResponse.statusCode == 200) {
        var data = jsonDecode(fetchResponse.body);
        return data['exists'];
      } else {
        print(
            'Failed to check colon file existence: ${fetchResponse.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error during HTTP request: $e');
      return false;
    }
  }

  Future<void> _checkColonFile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userKey = userProvider.user?.userKey;

    if (userKey != null) {
      bool exists = await _checkColonFileExists(
          widget.folderName, widget.noteName, userKey);
      setState(() {
        _isColonFileExists = exists;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(toolbarHeight: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      if (_recordingState == RecordingState.recording) {
                        showConfirmationDialog(
                          context,
                          "정말 녹음을 종료하시겠습니까?",
                          "녹음을 종료하면 다시 시작할 수 없습니다.",
                          () {
                            _stopRecording();
                          },
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LectureStartPage(
                                  fileName: widget.noteName,
                                  fileURL: widget.fileUrl)),
                        );
                      }
                    },
                    child: Text(
                      _recordingState == RecordingState.initial ? '취소' : '종료',
                      style: const TextStyle(
                        color: Color(0xFFFFA17A),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const ImageIcon(AssetImage('assets/folder_search.png')),
                  const SizedBox(width: 8),
                  Text(
                    '폴더 분류 > ${widget.folderName}',
                    style: const TextStyle(
                      color: Color(0xFF575757),
                      fontSize: 12,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                widget.noteName,
                style: const TextStyle(
                  color: Color(0xFF414141),
                  fontSize: 20,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '강의 자료: ${widget.lectureName}',
                style: const TextStyle(
                  color: Color(0xFF575757),
                  fontSize: 12,
                  fontFamily: 'DM Sans',
                ),
              ),
              if (_recordingState == RecordingState.recorded &&
                  _createdAt != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      _formatDate(_createdAt!),
                      style: const TextStyle(
                        color: Color(0xFF575757),
                        fontSize: 12,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (_recordingState == RecordingState.initial)
                    ClickButton(
                      text: '녹음',
                      onPressed: () {
                        setState(() {
                          _recordingState = RecordingState.recording;
                        });
                        _startRecording();
                      },
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: 40.0,
                      iconData: Icons.mic,
                    ),
                  if (_recordingState == RecordingState.recording)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClickButton(
                          text: '녹음종료',
                          onPressed: () {
                            showConfirmationDialog(
                              context,
                              "정말 녹음을 종료하시겠습니까?",
                              "녹음을 종료하면 다시 시작할 수 없습니다.",
                              () {
                                _stopRecording();
                              },
                            );
                          },
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 40.0,
                          iconData: Icons.mic,
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          children: [
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.fiber_manual_record,
                                    color: Color(0xFFFFA17A)),
                                SizedBox(width: 4),
                                Text(
                                  '녹음 중',
                                  style: TextStyle(
                                    color: Color(0xFFFFA17A),
                                    fontSize: 14,
                                    fontFamily: 'DM Sans',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  if (_recordingState == RecordingState.recorded)
                    Row(
                      children: [
                        ClickButton(
                          text: '녹음 종료됨',
                          onPressed: () {},
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 40.0,
                          iconData: Icons.mic_off,
                          iconColor: Colors.white,
                          backgroundColor: const Color(0xFF9FACBD),
                        ),
                        const SizedBox(width: 2),
                        ClickButton(
                          text: '콜론 생성(:)',
                          onPressed: _isColonFileExists
                              ? () {}
                              : () {
                                  print('콜론 생성 버튼 클릭됨');
                                  showColonCreatedDialog(
                                      context,
                                      widget.folderName,
                                      widget.noteName,
                                      widget.lectureName);
                                },
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 40.0,
                          backgroundColor: _isColonFileExists
                              ? Colors.grey
                              : const Color.fromRGBO(54, 174, 146, 1.0),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (_recordingState == RecordingState.recording)
                const Text(
                  '실시간 자막생성 중...',
                  style: TextStyle(
                    color: Color(0xFF414141),
                    fontSize: 16,
                    fontFamily: 'DM Sans',
                  ),
                ),
              if (isAlternativeTextEnabled &&
                  _recordingState == RecordingState.initial)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: _isPDF
                      ? SizedBox(
                          height: 600,
                          child: PdfView(
                            controller: _pdfController,
                          ),
                        )
                      : Image.network(
                          widget.fileUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Text(
                                '이미지를 불러올 수 없습니다.',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              if (_recordingState == RecordingState.recorded)
                const Text(
                  '실시간 자막',
                  style: TextStyle(
                    color: Color(0xFF414141),
                    fontSize: 16,
                    fontFamily: 'DM Sans',
                  ),
                ),
              const SizedBox(
                  height:
                      20), // Add some space at the bottom to prevent overflow
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}
