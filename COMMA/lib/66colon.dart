import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '60prepare.dart';
import 'components.dart';
import 'api/api.dart';

class ColonPage extends StatefulWidget {
  final String folderName; // 폴더 이름 가져오기 사용
  final String noteName; // 노트 이름 추가
  final String lectureName; // 강의 자료 이름 추가
  final dynamic createdAt; // 생성 날짜 및 시간 추가

  const ColonPage(
      {super.key,
      required this.folderName,
      required this.noteName,
      required this.lectureName,
      required this.createdAt});

  @override
  _ColonPageState createState() => _ColonPageState();
}

class _ColonPageState extends State<ColonPage> {
  int _selectedIndex = 2; // 학습 시작 탭이 기본 선택되도록 설정

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _formatDate(dynamic createdAt) {
    DateTime dateTime = DateTime.parse(createdAt);
    return DateFormat('yyyy/MM/dd hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LearningPreparation()),
                    );
                  },
                  child: const Text(
                    '종료',
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
                Image.asset('assets/folder_search.png'),
                const SizedBox(width: 8),
                Text(
                  '폴더 분류 > ${widget.folderName}', // 폴더 이름 사용
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
              widget.noteName, // 노트 이름 사용
              style: const TextStyle(
                color: Color(0xFF414141),
                fontSize: 20,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '강의 자료 : ${widget.lectureName}',
              style: const TextStyle(
                color: Color(0xFF575757),
                fontSize: 12,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 5), // 추가된 날짜와 시간을 위한 공간
            Text(
              _formatDate(widget.createdAt), // 데이터베이스에서 가져온 생성 날짜 및 시간 사용
              style: const TextStyle(
                color: Color(0xFF575757),
                fontSize: 12,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 20), // 강의 자료 밑에 여유 공간 추가
            Row(
              children: [
                ClickButton(
                  text: '콜론(:) 다운하기',
                  onPressed: () {},
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: 40.0,
                ),
              ],
            ),
            const SizedBox(height: 20),
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
      bottomNavigationBar:
          buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}
