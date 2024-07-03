import 'package:flutter/material.dart';
import '64popup_record.dart';
import '65popup_colon.dart';
import '62lecture_start.dart';

enum RecordingState { initial, recording, recorded }

class RecordPage extends StatefulWidget {
  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  int _currentIndex = 2; // 학습 시작 탭이 기본 선택되도록 설정
  RecordingState _recordingState = RecordingState.initial; // 녹음 상태를 나타내는 변수

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
                      showStopRecordingDialog(context, _stopRecording); // 팝업 창 표시
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LectureStartPage()),
                      );
                    }
                  },
                  child: Text(
                    _recordingState == RecordingState.initial ? '취소' : '종료',
                    style: TextStyle(
                      color: Color(0xFFFFA17A),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
<<<<<<< HEAD
                ImageIcon(AssetImage('/Users/bag-yena/StudioProjects/comma_script/lib/assets/folder_search.png')),
=======
                ImageIcon(AssetImage('assets/folder_search.png')),
>>>>>>> 80dd8e0076664cb755496179f9460b252c3bc1c3
                const SizedBox(width: 8),
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
            Text(
              '새로운 노트',
              style: TextStyle(
                color: Color(0xFF414141),
                fontSize: 20,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '강의 자료: Ch01. What is Algorithm?',
              style: TextStyle(
                color: Color(0xFF575757),
                fontSize: 12,
                fontFamily: 'DM Sans',
              ),
            ),
            if (_recordingState == RecordingState.recorded) // 녹음 종료됨일 때 날짜와 시간 표시
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
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
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _recordingState = RecordingState.recording; // 녹음 상태 변경
                      });
                    },
                    icon: Icon(Icons.mic, color: Colors.white),
                    label: Text(
                      '녹음',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0XFF36AE92),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                else if (_recordingState == RecordingState.recording)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          showStopRecordingDialog(context, _stopRecording); // 팝업 창 표시
                        },
                        icon: Icon(Icons.mic, color: Colors.white),
                        label: Text(
                          '녹음종료',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0XFF36AE92),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10), // 버튼과 텍스트 사이의 간격 추가
                      Column( // 텍스트를 아래로 내리기 위해 Column 사용
                        children: [
                          const SizedBox(height: 10), // 텍스트를 아래로 내리는 간격
                          Row(
                            children: [
                              Icon(Icons.fiber_manual_record, color: Color(0xFFFFA17A)),
                              const SizedBox(width: 4), // 아이콘과 텍스트 사이의 간격 추가
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
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              // 녹음 종료 버튼 눌렀을때 처리할 로직
                            });
                          },
                          icon: Icon(Icons.mic_off, color: Colors.white),
                          label: Text(
                            '녹음종료됨',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF9FACBD),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            showColonCreatedDialog(context); // 콜론 생성하기 버튼 기능 추가
                          },
                          child: Text(
                            '콜론(:) 생성하기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0XFF36AE92),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
              ],
            ),
            const SizedBox(height: 20),
            if (_recordingState == RecordingState.recording) // 녹음 중일 때 표시될 텍스트
              Text(
                '네 여러분 안녕하세요\n그래서 지난번에 공부한 Time Complexity 관련된 공식을 모두 공부해 오셨겠지요?\n다시 한 번 설명하지만 알고리즘에 있어서 Time complexity는 개발자라면 꼭 필수적으로 고려할 줄 알아야 하는 문제라고 했었음',
                style: TextStyle(
                  color: Color(0xFF414141),
                  fontSize: 16,
                  fontFamily: 'DM Sans',
                ),
              ),
            if (_recordingState == RecordingState.recorded) // 녹음 종료됨일 때 표시될 텍스트
              Text(
                '네 여러분 안녕하세요\n그래서 지난번에 공부한 Time Complexity 관련된 공식을 모두 공부해 오셨겠지요?\n다시 한 번 설명하지만 알고리즘에 있어서 Time complexity는 개발자라면 꼭 필수적으로 고려할 줄 알아야 하는 문제라고 했었음',
                style: TextStyle(
                  color: Color(0xFF414141),
                  fontSize: 16,
                  fontFamily: 'DM Sans',
                ),
              ),
            Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
<<<<<<< HEAD
            icon: ImageIcon(AssetImage('/Users/bag-yena/StudioProjects/comma_script/lib/assets/navigation_bar/home.png')),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('/Users/bag-yena/StudioProjects/comma_script/lib/assets/navigation_bar/folder.png')),
            label: '폴더',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('/Users/bag-yena/StudioProjects/comma_script/lib/assets/navigation_bar/learningstart.png')),
            label: '학습 시작',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('/Users/bag-yena/StudioProjects/comma_script/lib/assets/navigation_bar/mypage.png')),
=======
            icon: ImageIcon(AssetImage('assets/navigation_bar/home.png')),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/navigation_bar/folder.png')),
            label: '폴더',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/navigation_bar/learningstart.png')),
            label: '학습 시작',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/navigation_bar/mypage.png')),
>>>>>>> 80dd8e0076664cb755496179f9460b252c3bc1c3
            label: '마이페이지',
          ),
        ],
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.black,
        selectedIconTheme: IconThemeData(color: Colors.teal),
        unselectedIconTheme: IconThemeData(color: Colors.black),
        selectedLabelStyle: TextStyle(
          color: Colors.teal,
          fontSize: 9, // 글씨 크기 설정
          fontFamily: 'DM Sans', // 글씨체 설정
          fontWeight: FontWeight.bold,
        ), // 글씨 두께 설정),
        unselectedLabelStyle: TextStyle(
          color: Colors.black,
          fontSize: 9, // 글씨 크기 설정
          fontFamily: 'DM Sans', // 글씨체 설정
          fontWeight: FontWeight.bold,
        ),
        showUnselectedLabels: true, // 모든 텍스트 라벨을 항상 표시하도록 설정
      ),
    );
  }
}
