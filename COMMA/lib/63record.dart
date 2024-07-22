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
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sound_stream/sound_stream.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:async';
import 'dart:io';

import 'components.dart';
import 'api/api.dart';
import 'model/user_provider.dart';
import '62lecture_start.dart';
import '66colon.dart';
import 'env/env.dart';

enum RecordingState { initial, recording, recorded }

const serverUrl =
    'wss://api.deepgram.com/v1/listen?model=nova-2&encoding=linear16&sample_rate=16000&language=ko-KR';
const apiKey = 'e8f1fe0d8f088e4cf2e01a1f11dc190d60b37b2b';

class RecordPage extends StatefulWidget {
  final int? lecturefileId;
  final int? lectureFolderId;
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
    required this.lectureFolderId,
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
  bool _isColonCreated = false;
  int? _existColon;
  final ValueNotifier<double> progressNotifier = ValueNotifier<double>(0.0);
  List<Map<String, dynamic>> folderList = [];

  bool _isListening = false;
  String _recognizedText = '';
  String _interimText = '';

  final RecorderStream _recorder = RecorderStream();
  late StreamSubscription _recorderStatus;
  late StreamSubscription _audioStream;
  late IOWebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    _recordingState = widget.recordingState;
    if (_recordingState == RecordingState.recorded) {
      _fetchCreatedAt();
    }
    if (_recordingState == RecordingState.initial) {
      _insertInitialData();
    }
    if (_recordingState == RecordingState.recorded) {
      _checkExistColon();
    }
    _checkFileType();
    _loadPageTexts();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _requestPermissions();
    });
  }

  @override
  void dispose() {
    _recorderStatus.cancel();
    _audioStream.cancel();
    channel.sink.close();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
  }

  Future<void> _initStream() async {
    channel = IOWebSocketChannel.connect(Uri.parse(serverUrl),
        headers: {'Authorization': 'Token $apiKey'});

    channel.stream.listen((event) async {
      final parsedJson = jsonDecode(event);

      if (parsedJson.containsKey('is_final') && parsedJson['is_final']) {
        updateText(parsedJson['channel']['alternatives'][0]['transcript']);
      } else if (parsedJson.containsKey('channel')) {
        interimUpdateText(
            parsedJson['channel']['alternatives'][0]['transcript']);
      }
    });

    _audioStream = _recorder.audioStream.listen((data) {
      channel.sink.add(data);
    });

    _recorderStatus = _recorder.status.listen((status) {
      if (mounted) {
        setState(() {});
      }
    });

    await _recorder.initialize();
  }

  void _startRecord() async {
    resetText();
    await _initStream();
    await _recorder.start();
    setState(() {
      _isListening = true;
    });
  }

  void _stopRecord() async {
    await _recorder.stop();
    setState(() {
      _isListening = false;
    });
  }

  void onLayoutDone(Duration timeStamp) async {
    await Permission.microphone.request();
    setState(() {});
  }

  void updateText(newText) {
    setState(() {
      _recognizedText += ' ' + newText;
      _interimText = '';
    });
  }

  void interimUpdateText(newText) {
    setState(() {
      _interimText = newText;
    });
  }

  void resetText() {
    setState(() {
      _recognizedText = '';
    });
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
        _existColon = existColon;
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

  Future<String> fetchRecordUrl(int colonFileId) async {
    try {
      final response = await http.get(Uri.parse(
          '${API.baseUrl}/api/get-record-url?colonfileId=$colonFileId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('스크립트 잘 찾았어요 ${data['record_url']}');
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

    if (widget.type == 0) {
      print('Alt_table에 대체텍스트 url 저장하겠습니다');

      var altTableUrl = '${API.baseUrl}/api/alt-table';
      var altTableBody = {
        'lecturefile_id': widget.lecturefileId,
        'colonfile_id': null,
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
        await _loadPageTexts();
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
          '${API.baseUrl}/api/get-file-created-at?folderId=${widget.lectureFolderId}&fileName=${widget.noteName}');
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

  void _startRecording() async {
    setState(() {
      _recordingState = RecordingState.recording;
      _recognizedText = '';
      _interimText = '';
    });
    await _initStream();
    await _recorder.start();
    setState(() {
      _isListening = true;
    });
  }

  void _stopRecording() async {
    await _recorder.stop();
    setState(() {
      _recordingState = RecordingState.recorded;
      _isListening = false;
      _recognizedText += ' ' + _interimText;
      _interimText = '';
    });
    _saveTranscript();
    await _fetchCreatedAt();
  }

  Future<void> _saveTranscript() async {
    try {
      Uint8List fileBytes = Uint8List.fromList(utf8.encode(_recognizedText));

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userKey = userProvider.user?.userKey;
      if (userKey != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
            'record/$userKey/${widget.lectureFolderId}/${widget.lecturefileId}/자막.txt');

        UploadTask uploadTask = storageRef.putData(fileBytes,
            SettableMetadata(contentType: 'text/plain; charset=utf-8'));

        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadURL = await taskSnapshot.ref.getDownloadURL();
        print('Transcript uploaded: $downloadURL');

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

  Future<Map<String, String>> callChatGPT4API(List<String> imageUrls,
      String lectureScript, String lectureFileName) async {
    const String apiKey = Env.apiKey;
    final Uri apiUrl = Uri.parse('https://api.openai.com/v1/chat/completions');

    final String promptForPageScript = '''
  당신은 이미지 분석 전문가입니다. 당신에게 한 강의의 녹음본과, 해당 강의를 진행하는 데 사용된 강의 자료를 함께 드리겠습니다. 
  주어진 강의 자료가 여러 페이지일 텐데, 해당 자료의 내용을 숙지하여 강의의 녹음본을 강의 자료의 페이지별로 분할해 주세요. 
  상세 조건은 다음과 같습니다.
  조건:
  1. 강의의 녹음본을 제가 드린 강의 자료의 페이지 개수만큼의 섹션으로 분할해 주세요.
  2. 텍스트 파일의 이름은 page_{페이지 번호}.txt 형태로 해주세요. 번호는 0부터 시작합니다.
  3. 강의 자료를 분할하는 것 외에 부가적인 글자 수정은 하지 말아주세요. 스크립트의 글자 수정은 절대 금합니다. 페이지만 구분해주세요.
  4. 당신의 답변은 오직 다음의 패턴을 따릅니다 : '페이지 (쪽수)\n이미지 URL: (주소)\n스크립트: (내용)\n'. 
     이 형식 이외의 답변은 금지합니다.''';

    try {
      var pageScripts = <String, String>{};

      for (int i = 0; i < imageUrls.length; ++i) {
        var messages = [
          {'role': 'system', 'content': promptForPageScript},
          {
            'role': 'user',
            'content':
                '페이지 ${i}\n이미지 URL: ${imageUrls[i]}\n스크립트: $lectureScript'
          }
        ];

        var response = await http.post(
          apiUrl,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': 'gpt-4',
            'messages': messages,
            'max_tokens': 1000,
          }),
        );

        if (response.statusCode == 200) {
          var responseBody = utf8.decode(response.bodyBytes);
          var decodedResponse = jsonDecode(responseBody);
          var gptResponse = decodedResponse['choices'][0]['message']['content'];

          print('GPT-4 response content for page $i:');
          print(gptResponse);

          var matches = RegExp(
                  r'페이지 (\d+)\n이미지 URL: .+?\n스크립트: (.+?)(?=\n페이지 \d|\$)',
                  dotAll: true)
              .allMatches(gptResponse);
          for (var match in matches) {
            var pageIndex = match.group(1)!;
            var scriptContent = match.group(2)!.trim();
            pageScripts['page_$pageIndex.txt'] = scriptContent;

            print('Extracted script for page $pageIndex:');
            print(scriptContent);
          }
        } else {
          var responseBody = utf8.decode(response.bodyBytes);
          print('Error calling ChatGPT-4 API: ${response.statusCode}');
          print('Response body: $responseBody');
        }
      }

      return pageScripts;
    } catch (e) {
      print('Error: $e');
      return {};
    }
  }

  void _navigateToColonPage(BuildContext context, String folderName,
      String noteName, String lectureName, String createdAt) {
    try {
      print('Navigating to ColonPage');
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
                              lecturefileId: widget.lecturefileId,
                              lectureName: widget.lectureName,
                              fileURL: widget.fileUrl,
                              responseUrl: widget.responseUrl ?? '',
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
                        ClickButton(
                          text: _isColonCreated ? '콜론(:) 이동' : '콜론 생성(:)',
                          backgroundColor: _isColonCreated ? Colors.grey : null,
                          onPressed: () async {
                            if (_isColonCreated) {
                              print(_existColon);
                              var colonDetails =
                                  await _fetchColonDetails(_existColon!);
                              var colonFolderName = await _fetchColonFolderName(
                                  colonDetails['folder_id']);
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
                                  int colonFileId = await createColonFolder(
                                      "${widget.folderName} (:)",
                                      "${widget.noteName} (:)",
                                      widget.fileUrl,
                                      widget.lectureName,
                                      widget.type,
                                      userKey);

                                  if (colonFileId != -1) {
                                    await updateLectureFileWithColonId(
                                        widget.lecturefileId, colonFileId);
                                    await _updateRecordTableWithColonId(
                                        widget.lecturefileId, colonFileId);
                                    var colonDetails =
                                        await _fetchColonDetails(colonFileId);
                                    var colonFolderName =
                                        await _fetchColonFolderName(
                                            colonDetails['folder_id']);

                                    showColonCreatingDialog(
                                        context,
                                        colonDetails['file_name'],
                                        colonDetails['file_url'],
                                        progressNotifier);

                                    List<String> imageUrls = [];
                                    int pageIndex = 0;
                                    bool loadingImages = true;

                                    while (loadingImages) {
                                      try {
                                        String imageUrl = await FirebaseStorage
                                            .instance
                                            .ref(
                                                'uploads/$userKey/${widget.lectureFolderId}/${widget.lecturefileId}/pdf_handle/page_$pageIndex.jpg')
                                            .getDownloadURL();
                                        imageUrls.add(imageUrl);
                                        pageIndex++;
                                      } catch (e) {
                                        loadingImages = false;
                                      }
                                    }
                                    print('Loaded image URLs: $imageUrls');

                                    String scriptUrl =
                                        await fetchRecordUrl(colonFileId);
                                    String lectureScript = await http
                                        .get(Uri.parse(scriptUrl))
                                        .then((response) => response.body);

                                    Map<String, String> pageScripts =
                                        await callChatGPT4API(imageUrls,
                                            lectureScript, widget.lectureName);

                                    for (var i = 0;
                                        i < pageScripts.entries.length;
                                        i++) {
                                      var entry =
                                          pageScripts.entries.elementAt(i);
                                      String fileName = entry.key;
                                      String scriptContent = entry.value;

                                      print('Processing file: $fileName');

                                      final directory =
                                          await getTemporaryDirectory();
                                      final filePath =
                                          path.join(directory.path, fileName);

                                      final file = File(filePath);
                                      await file.writeAsString(scriptContent);

                                      print('File written: $filePath');

                                      final userProvider =
                                          Provider.of<UserProvider>(context,
                                              listen: false);
                                      final storageRef =
                                          FirebaseStorage.instance.ref().child(
                                              'response2/$userKey/${colonDetails['folder_id']}/${colonFileId}/${fileName}');

                                      print(
                                          'Firebase storage path: ${storageRef.fullPath}');

                                      UploadTask uploadTask =
                                          storageRef.putFile(file);

                                      TaskSnapshot taskSnapshot =
                                          await uploadTask;
                                      String responseUrl = await taskSnapshot
                                          .ref
                                          .getDownloadURL();
                                      print(
                                          'GPT Response stored URL: $responseUrl');

                                      progressNotifier.value =
                                          (i + 1) / pageScripts.entries.length;

                                      await file.delete();
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
                                    print('콜론 파일이랑 폴더 생성 실패한듯요 ...');
                                  }
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
              const SizedBox(height: 20),
              if (_recordingState == RecordingState.recording)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      _recognizedText + ' ' + _interimText,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              if (_recordingState == RecordingState.recorded)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      _recognizedText,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
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
