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
    'wss://api.deepgram.com/v1/listen?model=nova-2&encoding=linear16&sample_rate=16000&language=ko-KR&punctuate=true';
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
  final List<String>? keywords;

  const RecordPage(
      {super.key,
      this.lecturefileId,
      required this.lectureFolderId,
      required this.noteName,
      required this.fileUrl,
      required this.folderName,
      required this.recordingState,
      required this.lectureName,
      this.responseUrl,
      required this.type,
      this.keywords});

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
  int _currentLength = 0; // 자막 길이
  String combineText = ''; // 문단 구분 위한 변수

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

  String buildServerUrlWithKeywords(String baseUrl, List<String> keywordList) {
    final List<String> keywords = keywordList
        .expand((keyword) => keyword.split(','))
        .map((keyword) => keyword.trim())
        .toList();
    final keywordQuery =
        keywords.map((keyword) => 'keywords=$keyword').join('&');
    return '$baseUrl&$keywordQuery';
  }

  Future<void> _initStream() async {
    // 키워드가 있을 경우 serverUrl에 키워드 추가
    final String urlWithKeywords =
        buildServerUrlWithKeywords(serverUrl, widget.keywords!);
    print(urlWithKeywords);

    channel = IOWebSocketChannel.connect(Uri.parse(urlWithKeywords),
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

  void onLayoutDone(Duration timeStamp) async {
    await Permission.microphone.request();
    setState(() {});
  }

  void interimUpdateText(newText) {
    setState(() {
      _interimText = newText;
    });
  }

  void updateText(String newText) {
    setState(() {
      _interimText = '';
      final processedText = processParagraphs(newText);
      _recognizedText =
          _recognizedText + ' ' + processedText; // 처리된 텍스트를 기존 텍스트에 추가
    });
  }

  String processParagraphs(String newText) {
    const int maxLength = 200; // 단락을 나눌 텍스트의 최대 길이
    StringBuffer buffer = StringBuffer();

    combineText += newText;
    _currentLength = combineText.length;
    print(_currentLength);

    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      if (_currentLength >= maxLength &&
          (newText[i] == '.' || newText[i] == '?' || newText[i] == '!')) {
        buffer.write('\n\n'); // 단락을 나눌 때 개행 문자를 추가
        _currentLength = 0; // 카운트 초기화
        combineText = ''; // combineText 초기화
      }
    }
    // buffer.write(' ');
    return buffer.toString();
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
You are an expert in analyzing lecture scripts. I will provide you with a full lecture script and a series of lecture materials in the form of images. 
Your task is to identify and extract the part of the lecture script that corresponds to each page of the lecture material.
Please follow these instructions:
1. Do not modify any text in the lecture script.
2. Divide the lecture script into sections corresponding to each page of the lecture material.
3. The output should strictly follow this format: 'Page (page number)\nImage URL: (url)\nScript: (content)\n'.
4. Start the page number from 0.
5. Ensure that the response contains only the script corresponding to the specific page without generating new content or modifying the original script.
6. When given a specific page (e.g., page_0.jpg), only generate the script for that specific page.e
6. When given a specific page (e.g., page_0.jpg), only generate the script for that specific page.
7. '다음 페이지로 넘어가겠다' 등의 명시적인 지시어가 나오면, 페이지를 구분해 주세요.
8. 페이지를 구분하는 명시적인 대사가 없더라도, 강의 자료의 맥락상 해당 스크립트가 주어진 강의 사진의 상황과 일치하지 않는 것으로 판단되면 스크립트를 분할해 주세요.
''';

    try {
      var pageScripts = <String, String>{};

      for (int i = 0; i < imageUrls.length; ++i) {
        var messages = [
          {'role': 'system', 'content': promptForPageScript},
          {
            'role': 'user',
            'content':
                'Page ${i}\nImage URL: ${imageUrls[i]}\nLecture Script: $lectureScript\nGenerate the script for this specific page only.'
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

          var match =
              RegExp(r'Page (\d+)\nImage URL: .+?\nScript: (.+)', dotAll: true)
                  .firstMatch(gptResponse);
          if (match != null) {
            var pageIndex = match.group(1)!;
            var scriptContent = match.group(2)!.trim();
            pageScripts['page_$pageIndex.txt'] = scriptContent;

            print('Extracted script for page $pageIndex:');
            print(scriptContent);

            // Extract the remaining lecture script
            var scriptStartIndex = lectureScript.indexOf(scriptContent);
            if (scriptStartIndex != -1) {
              lectureScript = lectureScript
                  .substring(scriptStartIndex + scriptContent.length)
                  .trim();
            }
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

  void _navigateToColonPage(
      BuildContext context,
      String folderName,
      String noteName,
      String lectureName,
      String createdAt,
      String fileUrl,
      int colonFileId) {
    try {
      print('Navigating to ColonPage'); // 로그 추가
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ColonPage(
              folderName: "$folderName",
              noteName: "$noteName",
              lectureName: lectureName,
              createdAt: createdAt,
              fileUrl: fileUrl,
              colonFileId: colonFileId),
        ),
      );
    } catch (e) {
      print('Navigation error: $e');
    }
  }

  Future<void> insertDividedScript(
      int colonfileId, int page, String url) async {
    final apiUrl = '${API.baseUrl}/api/insertDividedScript';
    final body = jsonEncode({
      'colonfile_id': colonfileId,
      'page': page,
      'url': url,
    });

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      print('Divided script inserted successfully');
    } else {
      print('Failed to insert divided script: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  // 콜론 생성 다이얼로그 함수
  void showColonCreatedDialog(
      BuildContext context,
      String folderName,
      String noteName,
      String lectureName,
      String fileUrl,
      int? lectureFileId,
      int colonFileId) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userKey = userProvider.user?.userKey;

    if (userKey != null) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Column(
              children: [
                const Text(
                  '콜론이 생성되었습니다.',
                  style: TextStyle(
                    color: Color(0xFF545454),
                    fontSize: 14,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '폴더 이름: $folderName (:)', // 기본폴더 대신 folderName 사용
                  style: const TextStyle(
                    color: Color(0xFF245B3A),
                    fontSize: 14,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  '으로 이동하시겠습니까?',
                  style: TextStyle(
                    color: Color(0xFF545454),
                    fontSize: 14,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: <Widget>[
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          color: Color(0xFFFFA17A),
                          fontSize: 14,
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();

                        // `ColonPage`로 이동전 콜론 정보 가져오기
                        var colonDetails =
                            await _fetchColonDetails(colonFileId);
                        
                          await _insertColonFileIdToAltTable(
                              widget.lecturefileId!, colonFileId);
                        
                        //ColonFiles에 folder_id로 폴더 이름 가져오기
                        var colonFolderName = await _fetchColonFolderName(
                            colonDetails['folder_id']);

                        // 다이얼로그가 닫힌 후에 네비게이션을 실행
                        Future.delayed(Duration(milliseconds: 200), () {
                          _navigateToColonPage(
                              context,
                              colonFolderName,
                              colonDetails['file_name'],
                              colonDetails['lecture_name'],
                              colonDetails['created_at'],
                              colonDetails['file_url'],
                              colonFileId);
                        });
                      },
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          color: Color(0xFF545454),
                          fontSize: 14,
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    } else {
      print('User Key is null, cannot create colon folder.');
    }
  }

  Future<void> _insertColonFileIdToAltTable(
      int lecturefileId, int colonFileId) async {
    print('Alt_table에 colonfile_id 저장하겠습니다');

    var altTableUrl = '${API.baseUrl}/api/update-alt-table';
    var altTableBody = {
      'lecturefileId': lecturefileId,
      'colonFileId': colonFileId,
    };

    var altTableResponse = await http.post(
      Uri.parse(altTableUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(altTableBody),
    );

    if (altTableResponse.statusCode == 200) {
      print('Alt_table에 colonfile_id 저장 완료');
    } else {
      print(
          'Failed to add colonfile_id to alt table: ${altTableResponse.statusCode}');
      print(altTableResponse.body);
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

                                    //스크립트 가져오기
                                    String scriptUrl =
                                        await fetchRecordUrl(colonFileId);
                                    String lectureScript = await http
                                        .get(Uri.parse(scriptUrl))
                                        .then((response) => response.body);
                                    print(lectureScript);

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

                                      // URL을 데이터베이스에 삽입
                                      int pageIndex = int.parse(fileName
                                          .replaceAll(RegExp(r'[^0-9]'), ''));
                                      await insertDividedScript(
                                          colonFileId, pageIndex, responseUrl);

                                      await file.delete();
                                    }

                                    // (5)-1 CreatingDialog pop 하기

                                    progressNotifier.value =
                                        1.0; // 작업 완료 후 프로그레스 업데이트
                                    // (5)-2 CreatedDialog 호출하기
                                    //     이 안에서 생성된 콜론 화면으로 navigate
                                    showColonCreatedDialog(
                                        context,
                                        widget.folderName,
                                        widget.noteName,
                                        widget.lectureName,
                                        widget.fileUrl,
                                        widget.lecturefileId!,
                                        colonFileId);
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
