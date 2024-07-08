import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'components.dart';
import 'dart:convert';
import '62lecture_start.dart';
import 'package:intl/intl.dart';

enum RecordingState { initial, recording, recorded }

class RecordPage extends StatefulWidget {
  final String selectedFolderId; // 폴더 ID
  final String noteName;
  final String fileUrl; // 추가: 파일 URL
  final String folderName; // 추가: 폴더 이름
  final RecordingState recordingState;
  final String lectureName; // 추가: 강의자료 이름

  const RecordPage({
    Key? key,
    required this.selectedFolderId,
    required this.noteName,
    required this.fileUrl,
    required this.folderName,
    required this.recordingState,
    required this.lectureName, // 추가: 강의자료 이름
  }) : super(key: key);

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  late RecordingState _recordingState;
  int _selectedIndex = 2;
  dynamic _createdAt;

  @override
  void initState() {
    super.initState();
    _recordingState = widget.recordingState;
    if (_recordingState == RecordingState.recorded) {
      _fetchCreatedAt();
    }
  }

  Future<void> _fetchCreatedAt() async {
    var url = Uri.parse(
        'http://localhost:3000/api/get-file-created-at?folderId=${widget.selectedFolderId}&fileName=${widget.noteName}');
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

  void _stopRecording() {
    setState(() {
      _recordingState = RecordingState.recorded;
    });
  }

  Future<void> _startRecording() async {
    var url = 'http://localhost:3000/api/lecture-files';

    var body = {
      'folder_id': widget.selectedFolderId, // 선택한 폴더의 ID 사용
      'file_name': widget.noteName,
      'file_url': widget.fileUrl, // 다운로드 URL 사용
      'lecture_name': widget.lectureName, // 강의자료 이름 추가
    };

    // 확인용 로그 출력
    print('Sending HTTP POST request with data:');
    print('selectedFolderId: ${body['folder_id']}');
    print('noteName: ${body['file_name']}');
    print('fileUrl: ${body['file_url']}');
    print('lectureName: ${body['lecture_name']}');

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body), // Map을 JSON 문자열로 변환하여 전송
      );

      // HTTP 응답 확인을 위한 로그
      print('HTTP Response Code: ${response.statusCode}');
      print('HTTP Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // 성공적으로 추가된 경우 처리
        print('File added successfully');
        // TODO: 추가적으로 처리할 로직 추가
      } else {
        // 실패한 경우 처리
        print('Failed to add file: ${response.statusCode}');
        // TODO: 실패 처리 로직 추가
      }
    } catch (e) {
      // HTTP 요청 실패 시 처리
      print('Error during HTTP request: $e');
      // TODO: 실패 처리 로직 추가
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(toolbarHeight: 0),
      body: Padding(
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
                        "정말 녹음을 종료하시겠습니까?", // 다이얼로그 제목
                        "녹음을 종료하면 다시 시작할 수 없습니다.", // 다이얼로그 내용
                        () {
                          _stopRecording(); // 녹음을 종료상태
                        },
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LectureStartPage(fileName: widget.noteName, fileURL: widget.fileUrl)),
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
                ImageIcon(AssetImage('assets/folder_search.png')),
                SizedBox(width: 8),
                Text(
                  '폴더 분류 > ${widget.folderName}', // 폴더 이름 추가
                  style: TextStyle(
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
              style: TextStyle(
                color: Color(0xFF414141),
                fontSize: 20,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '강의 자료: ${widget.lectureName}', // 강의자료 이름 추가
              style: TextStyle(
                color: Color(0xFF575757),
                fontSize: 12,
                fontFamily: 'DM Sans',
              ),
            ),
            if (_recordingState == RecordingState.recorded && _createdAt != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    _formatDate(_createdAt!), // 포맷팅된 created_at 값 사용
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
                            "정말 녹음을 종료하시겠습니까?", // 다이얼로그 제목
                            "녹음을 종료하면 다시 시작할 수 없습니다.", // 다이얼로그 내용
                            () {
                              _stopRecording(); // 녹음을 종료하는 함수 호출
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
                              Icon(Icons.fiber_manual_record, color: Color(0xFFFFA17A)),
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
                        onPressed: () {
                          // 녹음 종료 버튼 눌렀을때 처리할 로직
                        },
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: 40.0,
                        iconData: Icons.mic_off,
                        iconColor: Colors.white,
                        backgroundColor: const Color(0xFF9FACBD),
                      ),
                      const SizedBox(width: 2),
                      ClickButton(
                        text: '콜론 생성(:)',
                        onPressed: () {
                          showColonCreatedDialog(context, widget.folderName, widget.noteName,widget.lectureName);
                        },
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: 40.0,
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
            if (_recordingState == RecordingState.recorded)
              const Text(
                '실시간 자막',
                style: TextStyle(
                  color: Color(0xFF414141),
                  fontSize: 16,
                  fontFamily: 'DM Sans',
                ),
              ),
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}
