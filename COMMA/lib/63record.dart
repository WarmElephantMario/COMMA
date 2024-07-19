import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_plugin/60prepare.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pdfx/pdfx.dart';
import 'dart:typed_data';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'components.dart';
import 'api/api.dart';
import 'model/user_provider.dart';
import '62lecture_start.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import '66colon.dart';

enum RecordingState { initial, recording, recorded }

class RecordPage extends StatefulWidget {
  final int? lecturefileId;
  final String selectedFolderId;
  final String noteName;
  final String fileUrl;
  final String folderName;
  final RecordingState recordingState;
  final String lectureName;
  final String? responseUrl;
  final int type;

  const RecordPage({
    super.key,
    this.lecturefileId,
    required this.selectedFolderId,
    required this.noteName,
    required this.fileUrl,
    required this.folderName,
    required this.recordingState,
    required this.lectureName,
    this.responseUrl,
    required this.type,
  });

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  late RecordingState _recordingState;
  int _selectedIndex = 2;
  dynamic _createdAt;
  bool _isPDF = false;
  PdfController? _pdfController;
  Uint8List? _fileBytes;
  int _currentPage = 1;
  final Set<int> _blurredPages = {};
  Map<int, String> pageTexts = {};
  bool _isColonCreated = false; // 추가: 콜론 생성 상태를 나타내는 프로퍼티
  int? _existColon; // 추가: existColon 값을 저장할 프로퍼티

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _recordingState = widget.recordingState;
    _speech = stt.SpeechToText();
    if (_recordingState == RecordingState.recorded) {
      _fetchCreatedAt();
    }
    if (_recordingState == RecordingState.initial) {
      _insertInitialData();
    }
    if (_recordingState == RecordingState.recorded) {
      _checkExistColon(); // 추가: 콜론 존재 여부 확인
    }
    _checkFileType();
    _loadPageTexts(); // 대체 텍스트 URL 로드
  }

  Future<void> _checkExistColon() async {
    var url =
        '${API.baseUrl}/api/check-exist-colon?lecturefileId=${widget.lecturefileId}';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var existColon = jsonResponse['existColon'];

      setState(() {
        _isColonCreated = existColon != null;
        _existColon = existColon; // existColon 값 저장
        print(_existColon);
      });

      if (existColon != null) {
        print('이미 생성된 콜론이 존재합니다. 콜론 이동 버튼으로 변환합니다.');
      }
    } else {
      print('Failed to check existColon: ${response.statusCode}');
      print(response.body);
    }
  }

  Future<Map<String, dynamic>> _fetchColonDetails(int colonId) async {
    var url = '${API.baseUrl}/api/get-colon-details?colonId=$colonId';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else {
      throw Exception('Failed to load colon details');
    }
  }

//콜론폴더 이름 확인하기
  Future<String> _fetchColonFolderName(int folderId) async {
    var url = '${API.baseUrl}/api/get-Colonfolder-name?folderId=$folderId';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return jsonResponse['folder_name'];
    } else {
      throw Exception('Failed to load folder name');
    }
  }

  Future<void> _loadPageTexts() async {
    if (widget.lecturefileId != null) {
      // 다른 페이지 타고 들어온 경우, widget.lecturefileId 사용하기
      // print('지금???? 1 ${widget.lecturefileId}');
      try {
        final response = await http.get(Uri.parse(
            '${API.baseUrl}/api/get-alternative-text-url?lecturefileId=${widget.lecturefileId}'));

        if (response.statusCode == 200) {
          print('Response body: ${response.body}');

          final fileData = jsonDecode(response.body);
          final alternativeTextUrl = fileData['alternative_text_url'];

          if (alternativeTextUrl != null) {
            final textResponse = await http.get(Uri.parse(alternativeTextUrl));
            if (textResponse.statusCode == 200) {
              final textLines = utf8.decode(textResponse.bodyBytes).split('//');
              setState(() {
                pageTexts = {
                  for (int i = 0; i < textLines.length; i++) i + 1: textLines[i]
                };
              });
            } else {
              print('Failed to fetch text file: ${textResponse.statusCode}');
            }
          } else {
            print('Alternative text URL is null');
          }
        } else {
          print('Failed to fetch alternative text URL: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } catch (e) {
        print('Error occurred: $e');
      }
    } else {
      // 페이지 최초 생성한 경우, _lecturefileId 사용하기
      // print('지금???? 2 ${_lecturefileId}');
      try {
        final response = await http.get(Uri.parse(
            '${API.baseUrl}/api/get-alternative-text-url?lecturefileId=${widget.lecturefileId}'));

        if (response.statusCode == 200) {
          print('Response body: ${response.body}');

          final fileData = jsonDecode(response.body);
          final alternativeTextUrl = fileData['alternative_text_url'];

          if (alternativeTextUrl != null) {
            final textResponse = await http.get(Uri.parse(alternativeTextUrl));
            if (textResponse.statusCode == 200) {
              final textLines = utf8.decode(textResponse.bodyBytes).split('\n');
              setState(() {
                pageTexts = {
                  for (int i = 0; i < textLines.length; i++) i + 1: textLines[i]
                };
              });
            } else {
              print('Failed to fetch text file: ${textResponse.statusCode}');
            }
          } else {
            print('Alternative text URL is null');
          }
        } else {
          print('Failed to fetch alternative text URL: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } catch (e) {
        print('Error occurred: $e');
      }
    }
  }

  void _toggleBlur(int page) {
    setState(() {
      if (_blurredPages.contains(page)) {
        _blurredPages.remove(page);
      } else {
        _blurredPages.add(page);
      }
    });
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
        _loadImageFile(widget.fileUrl);
      });
    } else {
      setState(() {
        _isPDF = false;
      });
    }
  }

  void _loadPdfFile(String url) async {
    final response = await http.get(Uri.parse(widget.fileUrl));
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

  void _loadImageFile(String url) async {
    final response = await http.get(Uri.parse(widget.fileUrl));
    if (response.statusCode == 200) {
      setState(() {
        _fileBytes = response.bodyBytes;
      });
    } else {
      print('Failed to load image file: ${response.statusCode}');
    }
  }

  Future<void> _insertInitialData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userKey = userProvider.user?.userKey;

    // 대체텍스트 타입일 때만 Alt_table에 추가로 데이터 저장
    if (widget.type == 0) {
      print('Alt_table에 대체텍스트 url 저장하겠습니다');

      var altTableUrl = '${API.baseUrl}/api/alt-table';
      var altTableBody = {
        'lecturefile_id': widget.lecturefileId,
        'colonfile_id': null, // 필요 시 적절한 colonfile_id 값을 제공
        'alternative_text_url': widget.responseUrl,
      };

      var altTableResponse = await http.post(
        Uri.parse(altTableUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(altTableBody),
      );

      if (altTableResponse.statusCode == 200) {
        print('Alt_table에 대체텍스트 url 저장 완료');
        print('대체텍스트 url 로드하겠습니다');
        await _loadPageTexts(); // 대체텍스트 로드
        print('대체텍스트 url 로드 완료');
      } else {
        print('Failed to add alt table entry: ${altTableResponse.statusCode}');
        print(altTableResponse.body);
      }
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

  Future<void> _startRecording() async {
    setState(() {
      _recordingState = RecordingState.recording;
    });

    // _listen(); // 녹음이 시작될 때 리스닝 시작
  }

  void _stopRecording() async {
    setState(() {
      _recordingState = RecordingState.recorded;
      _isListening = false;
    });
    _speech.stop(); // 녹음이 중지될 때 리스닝 중지
    await _saveTranscript(); // 녹음 종료 시 텍스트 파일로 저장 및 업로드
    await _fetchCreatedAt();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
        // options: [stt.SpeechToText.optionAndroidLocale, 'ko_KR'],
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _recognizedText = val.recognizedWords; // 텍스트 업데이트 (추가하지 않음)
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // 파이어베이스에 자막 txt 저장
  Future<void> _saveTranscript() async {
    try {
      Uint8List fileBytes = Uint8List.fromList(utf8.encode(_recognizedText));

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userKey = userProvider.user?.userKey;
      if (userKey != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
            'record/$userKey/${widget.selectedFolderId}/${widget.lecturefileId}/자막.txt');

        UploadTask uploadTask = storageRef.putData(fileBytes,
            SettableMetadata(contentType: 'text/plain; charset=utf-8'));

        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadURL = await taskSnapshot.ref.getDownloadURL();
        print('Transcript uploaded: $downloadURL');

        // Record_Table에 데이터 추가
        await _insertRecordData(widget.lecturefileId, null, downloadURL);
      } else {
        print('User ID is null, cannot save transcript.');
      }
    } catch (e) {
      print('Error saving transcript: $e');
    }
  }

  Future<void> _insertRecordData(
      int? lecturefileId, int? colonfileId, String downloadURL) async {
    final url = '${API.baseUrl}/api/insertRecordData';
    final body = {
      'lecturefile_id': lecturefileId,
      'colonfile_id': colonfileId,
      'record_url': downloadURL,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Record added successfully');
      } else {
        print('Failed to add record: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('Error adding record: $e');
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
                              lecturefileId: widget.lecturefileId, // Inserted ID 전달
                              lectureName: widget.lectureName,
                              fileURL: widget.fileUrl,
                              responseUrl: widget.responseUrl ?? '', // null일 경우 빈 문자열 전달
                              type: widget.type, 
                              selectedFolder: widget.folderName,
                              noteName: widget.noteName,
                            ),
                          ),
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
                  Image.asset('assets/folder_search.png'),
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
              // 녹음 종료 후 시간 표시
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
                        _startRecording();
                        _listen();
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
                        )
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
                          backgroundColor: Colors.grey,
                        ),
                        const SizedBox(width: 2),
                        // 콜론 생성 버튼 클릭 시 로직 추가 부분
                        // >> 스크립트랑 강의자료 보내서 찢어달라고 요청하기
                        ClickButton(
                          text: _isColonCreated ? '콜론(:) 이동' : '콜론 생성(:)',
                          backgroundColor: _isColonCreated ? Colors.grey : null,
                          onPressed: () async {
                            if (_isColonCreated) {
                              print(_existColon);
                              // `ColonPage`로 이동전 콜론 정보 가져오기
                              var colonDetails =
                                  await _fetchColonDetails(_existColon!);
                              //ColonFiles에 folder_id로 폴더 이름 가져오기
                              var colonFolderName = await _fetchColonFolderName(
                                  colonDetails['folder_id']);
                              //print('folderName: $colonFolderName');

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ColonPage(
                                    folderName: colonFolderName,
                                    noteName: colonDetails['file_name'],
                                    lectureName: colonDetails['lecture_name'],
                                    createdAt: colonDetails['created_at'],
                                    fileUrl: colonDetails['file_url'],
                                  ),
                                ),
                              );
                            } else {
                              print('콜론 생성 버튼 클릭됨');
                              var url =
                                  '${API.baseUrl}/api/check-exist-colon?lecturefileId=${widget.lecturefileId}';
                              var response = await http.get(Uri.parse(url));

                              if (response.statusCode == 200) {
                                var jsonResponse = jsonDecode(response.body);
                                var existColon = jsonResponse['existColon'];

                                if (existColon == null) {
                                  showColonCreatedDialog(
                                    context,
                                    widget.folderName,
                                    widget.noteName,
                                    widget.lectureName,
                                    widget.fileUrl,
                                    widget.lecturefileId!,
                                  );
                                } else {
                                  print(
                                      '이미 생성된 콜론이 존재합니다. 콜론 생성 다이얼로그를 실행하지 않습니다.');
                                }
                              } else {
                                print(
                                    'Failed to check existColon: ${response.statusCode}');
                                print(response.body);
                              }
                            }
                          },
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 40.0,
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (isAlternativeTextEnabled)
                GestureDetector(
                  onTap: () {
                    _toggleBlur(_currentPage);
                  },
                  child: Stack(
                    children: [
                      if (_isPDF)
                        SizedBox(
                          height: 600,
                          child: PdfView(
                            controller: _pdfController!,
                            onPageChanged: (page) {
                              setState(() {
                                _currentPage = page;
                              });
                            },
                          ),
                        ),
                      if (!_isPDF && _fileBytes != null)
                        Image.memory(_fileBytes!),
                      if (_blurredPages.contains(_currentPage))
                        Container(
                          height: 600,
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: Text(
                              pageTexts.isNotEmpty
                                  ? pageTexts[_currentPage] ??
                                      '페이지 $_currentPage의 텍스트가 없습니다.'
                                  : '텍스트가 없습니다.',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 20), // 녹음 상태와 관계없이 항상 표시
              if (_recordingState == RecordingState.recording &&
                  isRealTimeSttEnabled == true)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      _recognizedText,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              if (_recordingState == RecordingState.recorded &&
                  isRealTimeSttEnabled == true)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      _recognizedText,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}
