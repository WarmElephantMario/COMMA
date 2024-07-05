import 'package:flutter/material.dart';
import 'components.dart';

class LearningPreparation extends StatefulWidget {
  @override
  _LearningPreparationState createState() => _LearningPreparationState();
}

class _LearningPreparationState extends State<LearningPreparation> {
  int _selectedOption = 0;
  bool _isMaterialEmbedded = false; // 강의 자료가 임베드되었는지 여부를 관리하는 변수
  bool _isIconVisible = true; // 아이콘이 보이는지 여부를 관리하는 변수

  // void _showConfirmationDialog(BuildContext context, String title, String message, VoidCallback onConfirm) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(title),
  //         content: Text(message),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('취소', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFFFFA17A))),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               onConfirm();
  //             },
  //             child: const Text('확인', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF545454))),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _buildRadioOption(String text, int value) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: _selectedOption,
          onChanged: (value) {
            setState(() {
              _selectedOption = value!;
            });
          },
          activeColor: Color(0xFF36AE92),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Color(0xFF414141),
            fontSize: 16,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialInfo() {
    if (_isMaterialEmbedded) {
      return Column(
        children: [
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '인공지능_ch03_algorithm.pdf',
                      style: TextStyle(
                        color: Color(0xFF575757),
                        fontSize: 15,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      '2024년 6월 11일  845kb',
                      style: TextStyle(
                        color: Color(0xFF575757),
                        fontSize: 14,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // Hide the AppBar
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white, // 화면 백그라운드 색상을 흰색으로 설정
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 15),
          Text(
            '오늘의 학습 준비하기',
            style: TextStyle(
              color: Color(0xFF414141),
              fontSize: 24,
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            '학습 유형을 선택해주세요.',
            style: TextStyle(
              color: Color(0xFF575757),
              fontSize: 16,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 30),
          _buildRadioOption('대체텍스트 생성', 0),
          _buildRadioOption('실시간 자막 생성', 1),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  if (_isMaterialEmbedded) {
                    showLearningDialog(context); // 버튼 클릭 시 팝업 창 표시
                  } else {
                    _isMaterialEmbedded = true; // 버튼 클릭 시 상태 업데이트
                    _isIconVisible = false; // 아이콘 숨기기
                  }
                });
              },
              icon: _isIconVisible
                  ? ImageIcon(
                      AssetImage('assets/Vector.png'),
                      color: Colors.white,
                    )
                  : Container(), // 아이콘이 보이지 않도록 빈 컨테이너 사용
              label: Text(
                _isMaterialEmbedded ? '강의 자료 학습 시작하기' : '강의 자료를 임베드하세요',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.bold,
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
          ),
          _buildMaterialInfo(),
        ],
      ),
    );
  }
}
