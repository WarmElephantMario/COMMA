import 'package:flutter/material.dart';
import 'package:flutter_plugin/model/user.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'components.dart';
import '63record.dart';
import 'package:provider/provider.dart';
import 'model/user_provider.dart';
import 'api/api.dart';
import '../model/44_font_size_provider.dart';


class LectureStartPage extends StatefulWidget {
  final int? lectureFolderId;
  final int? lecturefileId;
  final String lectureName;
  final String fileURL;
  final String? responseUrl;
  final int type;
  final String? selectedFolder;
  final String? noteName;
  final List<String>? keywords;

  const LectureStartPage(
      {super.key,
      this.lectureFolderId,
      this.lecturefileId,
      required this.lectureName,
      required this.fileURL,
      this.responseUrl,
      required this.type,
      this.selectedFolder,
      this.noteName,
      this.keywords});

  @override
  _LectureStartPageState createState() => _LectureStartPageState();
}

class _LectureStartPageState extends State<LectureStartPage> {
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    // 키워드가 잘 넘어왔는지 확인하기 위해 콘솔에 출력
    print("LectureStartPage Keywords: ${widget.keywords}");
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 폰트 크기 비율을 Provider에서 가져옴
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    // 디스플레이 비율을 가져옴
    final scaleFactor = fontSizeProvider.scaleFactor;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
             Text(
              '오늘의 학습 시작하기',
              style: TextStyle(
                color: Color(0xFF414141),
                fontSize: 24*scaleFactor,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 30),
             Text(
              '업로드 한 강의 자료의 AI 학습이 완료되었어요!\n학습을 시작하려면 강의실에 입장하세요.',
              style: TextStyle(
                color: Color(0xFF575757),
                fontSize: 14*scaleFactor,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.lectureName,
                          style:  TextStyle(
                            color: Color(0xFF575757),
                            fontSize: 15*scaleFactor,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            GestureDetector(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/folder_search.png'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '폴더 분류 > ${widget.selectedFolder}',
                      style:  TextStyle(
                        color: Color(0xFF575757),
                        fontSize: 12*scaleFactor,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              child: Row(
                children: [
                  Image.asset('assets/text.png'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.noteName!,
                      style:  TextStyle(
                        color: Color(0xFF575757),
                        fontSize: 12*scaleFactor,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
            Center(
              child: ClickButton(
                text: '강의실 입장하기',
                onPressed: () async{
                   // lecturefileId에 existLecture 값을 1로 업데이트하는 API 호출
                if (widget.lecturefileId != null) {
                  print("existLecture update");
                  print(widget.lecturefileId);
                  try {
                    final response = await http.post(
                      Uri.parse('${API.baseUrl}/api/update-existLecture'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'lecturefileId': widget.lecturefileId
                      }),
                    );

                    if (response.statusCode == 200) {
                      
                      print('existLecture 업데이트 성공');
                    } else {
                      print('existLecture 업데이트 실패');
                      print('Response status: ${response.statusCode}');
                      print('Response body: ${response.body}');
                    }
                  } catch (e) {
                    // 에러 발생 시 예외 메시지 출력
                    print('Error occurred during existLecture update: $e');
                  }
                }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecordPage(
                        lectureFolderId: widget.lectureFolderId!,
                        noteName: widget.noteName!,
                        fileUrl: widget.fileURL,
                        folderName: widget.selectedFolder!,
                        recordingState: RecordingState.initial,
                        lectureName: widget.lectureName,
                        responseUrl: widget.responseUrl != null
                            ? widget.responseUrl
                            : null,
                        type: widget.type, //대체인지 실시간인지 전달해줌
                        lecturefileId: widget.lecturefileId,
                        keywords: widget.keywords,
                      ),
                    ),
                  );
                },
                width: MediaQuery.of(context).size.width * 0.5,
                height: 50.0,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar:
          buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}
