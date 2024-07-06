import 'package:flutter/material.dart';
import 'components.dart';
import '62lecture_start.dart';

enum RecordingState { initial, recording, recorded }

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  RecordingState _recordingState = RecordingState.initial; // 녹음 상태를 나타내는 변수
  int _selectedIndex = 2; // 학습 시작 탭이 기본 선택되도록 설정

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // Hide the AppBar
      ),
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
                        MaterialPageRoute(builder: (context) => LectureStartPage()),
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
            const Row(
              children: [
                ImageIcon(AssetImage('assets/folder_search.png')),
                SizedBox(width: 8),
                Text(
                  '폴더 분류 > 기본 폴더',
                  style: TextStyle(
                    color: Color(0xFF575757),
                    fontSize: 12,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            const Text(
              '새로운 노트',
              style: TextStyle(
                color: Color(0xFF414141),
                fontSize: 20,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              '강의 자료: Ch01. What is Algorithm?',
              style: TextStyle(
                color: Color(0xFF575757),
                fontSize: 12,
                fontFamily: 'DM Sans',
              ),
            ),
            if (_recordingState == RecordingState.recorded) // 녹음 종료됨일 때 날짜와 시간 표시
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text(
                    '2024/06/07 오후 2:30',
                    style: TextStyle(
                      color: Color(0xFF575757),
                      fontSize: 12,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20), // 강의 자료 밑에 여유 공간 추가
            Row(
              children: [
                if (_recordingState == RecordingState.initial)
                  ClickButton(
                    text: '녹음',
                    onPressed: () {
                      setState(() {
                        _recordingState = RecordingState.recording; // 녹음 상태 변경
                      });
                    },
                    width: MediaQuery.of(context).size.width * 0.25, // 원하는 너비 설정
                    height: 40.0, // 원하는 높이 설정
                    iconData: Icons.mic,
                  )
                else if (_recordingState == RecordingState.recording)
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
                        width: MediaQuery.of(context).size.width * 0.3, // 원하는 너비 설정
                        height: 40.0, // 원하는 높이 설정
                        iconData: Icons.mic,
                      ),
                      const SizedBox(width: 10), // 버튼과 텍스트 사이의 간격 추가
                      const Column(
                        // 텍스트를 아래로 내리기 위해 Column 사용
                        children: [
                          SizedBox(height: 10), // 텍스트를 아래로 내리는 간격
                          Row(
                            children: [
                              Icon(Icons.fiber_manual_record, color: Color(0xFFFFA17A)),
                              SizedBox(width: 4), // 아이콘과 텍스트 사이의 간격 추가
                              Text(
                                '녹음중',
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
                  )
                else if (_recordingState == RecordingState.recorded)
                  Row(
                    children: [
                      ClickButton(
                        text: '녹음종료됨',
                        onPressed: () {
                          // 녹음 종료 버튼 눌렀을때 처리할 로직
                        },
                        width: MediaQuery.of(context).size.width * 0.3, // 원하는 너비 설정
                        height: 40.0, // 원하는 높이 설정
                        iconData: Icons.mic_off,
                        iconColor: Colors.white,
                        backgroundColor: const Color(0xFF9FACBD), // 배경색 설정
                      ),
                      const SizedBox(width: 2), // 두 버튼 사이의 간격을 줄임
                      ClickButton(
                        text: '콜론(:) 생성하기',
                        onPressed: () {
                          showColonCreatedDialog(context); // 콜론 생성하기 버튼 기능 추가
                        },
                        width: MediaQuery.of(context).size.width * 0.3, // 원하는 너비 설정
                        height: 40.0, // 원하는 높이 설정
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (_recordingState == RecordingState.recording) // 녹음 중일 때 표시될 텍스트
              const Text(
                '네 여러분 안녕하세요\n그래서 지난번에 공부한 Time Complexity 관련된 공식을 모두 공부해 오셨겠지요?\n다시 한 번 설명하지만 알고리즘에 있어서 Time complexity는 개발자라면 꼭 필수적으로 고려할 줄 알아야 하는 문제라고 했었음',
                style: TextStyle(
                  color: Color(0xFF414141),
                  fontSize: 16,
                  fontFamily: 'DM Sans',
                ),
              ),
            if (_recordingState == RecordingState.recorded) // 녹음 종료됨일 때 표시될 텍스트
              const Text(
                '네 여러분 안녕하세요\n그래서 지난번에 공부한 Time Complexity 관련된 공식을 모두 공부해 오셨겠지요?\n다시 한 번 설명하지만 알고리즘에 있어서 Time complexity는 개발자라면 꼭 필수적으로 고려할 줄 알아야 하는 문제라고 했었음',
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
