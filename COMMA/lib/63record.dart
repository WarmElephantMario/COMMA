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
import 'env/env.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';


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
  final int? savedFolderId;

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
    this.savedFolderId,
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
  final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(0.0);
  List<Map<String, dynamic>> folderList = [];

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

  int getFolderIdByName(String folderName) {
    return folderList.firstWhere(
        (folder) => folder['folder_name'] == folderName,
        orElse: () => {'id': -1})['id'];
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

//강의 스크립트 저장된 것 가져오기
  Future<String> fetchRecordUrl(int colonFileId) async {
    try {
      final response = await http.get(Uri.parse(
          '${API.baseUrl}/api/get-record-url?colonfileId=$colonFileId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['record_url'];
      } else {
        throw Exception('Failed to fetch record URL');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw e;
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

  // 콜론 폴더 생성 및 파일 생성 함수
  Future<int> createColonFolder(String folderName, String noteName,
      String fileUrl, String lectureName, int type, int? userKey) async {
    var url = '${API.baseUrl}/api/create-colon';

    var body = {
      'folderName': folderName,
      'noteName': noteName,
      'fileUrl': fileUrl,
      'lectureName': lectureName,
      'type': type,
      'userKey': userKey,
    };

    try {
      print('Sending request to $url with body: $body');

      var response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print('Folder and file created successfully');
        print('Colon File ID: ${jsonResponse['colonFileId']}');
        return jsonResponse['colonFileId'];
        //return jsonResponse['folder_id'];
      } else {
        print('Failed to create folder and file: ${response.statusCode}');
        print('Response body: ${response.body}');
        return -1;
      }
    } catch (e) {
      print('Error during HTTP request: $e');
      return -1;
    }
  }

  Future<void> updateLectureFileWithColonId(
      int? lectureFileId, int colonFileId) async {
    var url = '${API.baseUrl}/api/update-lecture-file';

    var body = {
      'lectureFileId': lectureFileId,
      'colonFileId': colonFileId,
    };

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Lecture file updated successfully with colonFileId');
      } else {
        print('Failed to update lecture file: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error during HTTP request: $e');
    }
  }

// Record_Table 업데이트 함수
  Future<void> _updateRecordTableWithColonId(
      int? lecturefileId, int colonfileId) async {
    final updateUrl = '${API.baseUrl}/api/update-record-table';
    final updateBody = {
      'lecturefile_id': lecturefileId,
      'colonfile_id': colonfileId,
    };

    try {
      final updateResponse = await http.post(
        Uri.parse(updateUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updateBody),
      );

      if (updateResponse.statusCode == 200) {
        print('Record table updated successfully with colon file ID');
      } else {
        print('Failed to update record table: ${updateResponse.statusCode}');
        print(updateResponse.body);
      }
    } catch (e) {
      print('Error updating record table: $e');
    }
  }

  Future<Map<String, String>> callChatGPT4API(
      List<String> imageUrls,
      String lectureScript,
      String lectureFileName) async {
    const String apiKey = Env.apiKey;
    final Uri apiUrl = Uri.parse('https://api.openai.com/v1/chat/completions');

    final String promptForPageScript = '''
    당신은 이미지 분석 전문가입니다. 다음은 강의 자료의 페이지와 해당하는 스크립트입니다. 
    각 페이지의 스크립트를 텍스트 파일로 분할해 주세요.
    조건:
    1. 각 페이지별로 텍스트 파일을 생성해 주세요.
    2. 텍스트 파일의 이름은 page_{페이지 번호}.txt 형태로 해주세요.
    3. 스크립트를 가능한 한 정확하게 분할해 주세요.
  ''';

    try {
      // 메시지 구성
      var messages = imageUrls.asMap().entries.map((entry) {
        int index = entry.key;
        String imageUrl = entry.value;
        return {
          'role': 'user',
          'content': {
            'type': 'image_url',
            'image_url': imageUrl,
            'script': lectureScript,
            'instruction': '페이지 번호에 맞게 스크립트를 분할해 주세요.'
          }
        };
      }).toList();

      var response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {'role': 'system', 'content': promptForPageScript},
            ...messages
          ],
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        var responseBody = utf8.decode(response.bodyBytes);
        var decodedResponse = jsonDecode(responseBody);
        var gptResponse = decodedResponse['choices'][0]['message']['content'];

        // 응답을 페이지별 텍스트로 분할
        var pageScripts = <String, String>{};
        var matches =
            RegExp(r'\[page_(\d+)\.txt\]\n(.+?)(?=\n\[|$)', dotAll: true)
                .allMatches(gptResponse);
        for (var match in matches) {
          var pageIndex = match.group(1)!;
          var scriptContent = match.group(2)!.trim();
          pageScripts['page_$pageIndex.txt'] = scriptContent;
        }
        return pageScripts; // 페이지별 텍스트 파일 내용을 반환

      } else {
        var responseBody = utf8.decode(response.bodyBytes);
        print('Error calling ChatGPT-4 API: ${response.statusCode}');
        print('Response body: $responseBody');
        return {};
      }
    } catch (e) {
      print('Error: $e');
      return {};
    }
  }

//여기다 fileUrl 추가하라고.. ->
  void _navigateToColonPage(BuildContext context, String folderName,
      String noteName, String lectureName, String createdAt) {
    try {
      print('Navigating to ColonPage'); // 로그 추가
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ColonPage(
            folderName: "$folderName",
            noteName: "$noteName (:)",
            lectureName: lectureName,
            createdAt: createdAt,
          ),
        ),
      );
    } catch (e) {
      print('Navigation error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userKey = userProvider.user?.userKey;

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
                              lecturefileId:
                                  widget.lecturefileId, // Inserted ID 전달
                              lectureName: widget.lectureName,
                              fileURL: widget.fileUrl,
                              responseUrl:
                                  widget.responseUrl ?? '', // null일 경우 빈 문자열 전달
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

                        // 콜론 생성 버튼 클릭 시
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

                                //기존에 colon이 없던 경우. 새로 생성함
                                if (existColon == null) {
                                  // (1) 바로 콜론 폴더 및 파일 생성하기
                                  int colonFileId = await createColonFolder(
                                      //..이상하게 타입 추가가 안됨
                                      "${widget.folderName} (:)",
                                      "${widget.noteName} (:)",
                                      widget.fileUrl,
                                      widget.lectureName,
                                      widget.type,
                                      userKey);

                                  if (colonFileId != -1) {
                                    //colon folder와 file 성공적으로 생성 시
                                    await updateLectureFileWithColonId(
                                        //연관 강의파일-콜론파일 연결해줌
                                        widget.lecturefileId,
                                        colonFileId);
                                    await _updateRecordTableWithColonId(
                                        //Record 테이블에 콜론 파일 id 저장
                                        widget.lecturefileId,
                                        colonFileId);
                                    var colonDetails = await _fetchColonDetails(
                                        colonFileId); // 새로 생성한 콜론 정보 가져오기 (fetch)
                                    var colonFolderName = // folder_id로 ColonFile이 들어있는 폴더 이름 가져오기
                                        await _fetchColonFolderName(
                                            colonDetails['folder_id']);

                                    // (2) showColonCreatingDialog 호출하기 (현황 보여주기)
                                    showColonCreatingDialog(
                                        context,
                                        colonDetails['file_name'],
                                        colonDetails['file_url'],
                                        _progressNotifier);

                                    // (3) gpt 불러서 강의자료&자막 주고 찢어달라 하기 -> 파이어베이스 저장

                                    List<String> imageUrls = [];
                                    int pageIndex = 0;
                                    bool loadingImages = true;

                                    // Firebase Storage에서 강의 자료 사진 로드
                                    while (loadingImages) {
                                      print('uploads/$userKey/${widget.savedFolderId}/${widget.lecturefileId}/pdf_handle/page_$pageIndex.jpg');
                                      try {
                                        String imageUrl = await FirebaseStorage.instance
                                          .ref('uploads/$userKey/${widget.savedFolderId}/${widget.lecturefileId}/pdf_handle/page_$pageIndex.jpg')
                                          .getDownloadURL();
                                        imageUrls.add(imageUrl);
                                        pageIndex++;
                                      } catch (e) {
                                        print('여기서오류났어요');
                                        loadingImages = false;
                                      }
                                    }

                                    print('Loaded image URLs: $imageUrls');

                                    // Record_table에서 강의 스크립트 .txt 파일 로드
                                    String scriptUrl =
                                        await fetchRecordUrl(colonFileId);
                                    String lectureScript = await http
                                        .get(Uri.parse(scriptUrl))
                                        .then((response) => response.body);

                                  // 두 개 한꺼번에 주면서 gpt 호출 (찢어달라고 하기)
                                  Map<String, String> pageScripts = await callChatGPT4API(
                                    imageUrls,
                                    lectureScript,
                                    widget.lectureName
                                );

                                // Firebase에 페이지별 스크립트 저장 및 URL 수집
                                for (var entry in pageScripts.entries) {
                                  String fileName = entry.key;
                                  String scriptContent = entry.value;

                                  // Get temporary directory to store the file
                                  final directory = await getTemporaryDirectory();
                                  final filePath = path.join(directory.path, fileName);

                                  // Write script content to .txt file
                                  final file = File(filePath);
                                  await file.writeAsString(scriptContent);

                                  // Define the storage path
                                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                                  final storageRef = FirebaseStorage.instance.ref().child(
                                      'response2/$userKey/${colonDetails['folder_id']}/${path.basename(filePath)}');
                                  UploadTask uploadTask = storageRef.putFile(file);

                                  TaskSnapshot taskSnapshot = await uploadTask;
                                  String responseUrl = await taskSnapshot.ref.getDownloadURL();
                                  print('GPT Response stored URL: $responseUrl');

                                  // Optionally delete the temporary file
                                  await file.delete();
                                }

                                  // (4) 저장 url sql에 삽입하기

                                  // (5) CreatingDialog pop 하고 CreatedDialog 호출하기.
                                  //     이 안에서 생성된 콜론 화면으로 navigate

                                  // // 다이얼로그가 닫힌 후에 네비게이션을 실행
                                  // Future.delayed(Duration(milliseconds: 200),
                                  //     () {
                                  //   _navigateToColonPage(
                                  //       context,
                                  //       colonFolderName,
                                  //       widget.noteName,
                                  //       widget.lectureName,
                                  //       colonDetails['created_at']);
                                  //       fileUrl 추가해야 한다고 함 (예나 PR)
                                  // });


                                  } else {
                                    print('콜론 파일이랑 폴더 생성 실패한듯요 ...');
                                  }

                                  showColonCreatedDialog(
                                    context,
                                    widget.folderName,
                                    widget.noteName,
                                    widget.lectureName,
                                    widget.fileUrl,
                                    widget.lecturefileId!,
                                  );
                                } else {
                                  //기존에 콜론이 존재하던 경우.
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
