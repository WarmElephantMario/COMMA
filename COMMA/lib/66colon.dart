import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdfx/pdfx.dart'; // PDF 렌더링 패키지 추가
import 'package:http/http.dart' as http; // HTTP 패키지 추가
import '60prepare.dart';
import 'components.dart';
import 'api/api.dart';
import 'dart:typed_data';

class ColonPage extends StatefulWidget {
  final String folderName; // 폴더 이름 가져오기 사용
  final String noteName; // 노트 이름 추가
  final String lectureName; // 강의 자료 이름 추가
  final dynamic createdAt; // 생성 날짜 및 시간 추가
  final String? fileUrl; // 강의자료 추가, 선택 사항으로 만듦

  const ColonPage({
    Key? key,
    required this.folderName,
    required this.noteName,
    required this.lectureName,
    required this.createdAt,
    this.fileUrl,
  }) : super(key: key);

  @override
  _ColonPageState createState() => _ColonPageState();
}

class _ColonPageState extends State<ColonPage> {
  bool isLoading = true;
  List<PdfPageImage> pages = [];
  Uint8List? imageData;
  int _selectedIndex = 2;
  final Map<int, String> pageTexts = {
    1: '첫 번째 페이지의 텍스트',
    2: '두 번째 페이지의 텍스트',
    3: '세 번째 페이지의 텍스트',
    // 필요한 만큼 페이지 번호와 텍스트를 추가하세요.
  };

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadFile() async {
    if (widget.fileUrl != null) {
      final response = await http.get(Uri.parse(widget.fileUrl!));
      if (response.statusCode == 200) {
        if (widget.lectureName.endsWith('.pdf')) {
          final document = await PdfDocument.openData(response.bodyBytes);
          for (int i = 1; i <= document.pagesCount; i++) {
            final page = await document.getPage(i);
            final pageImage = await page.render(
              width: page.width,
              height: page.height,
              format: PdfPageImageFormat.jpeg,
            );
            pages.add(pageImage!);
            await page.close();
          }
        } else if (widget.lectureName.endsWith('.png') ||
            widget.lectureName.endsWith('.jpg') ||
            widget.lectureName.endsWith('.jpeg')) {
          imageData = response.bodyBytes;
        }
        setState(() {
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load file');
      }
    }
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                                      builder: (context) =>
                                          const LearningPreparation()),
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
                      ],
                    ),
                  ),
                  if (widget.lectureName.endsWith('.pdf') &&
                      widget.fileUrl != null)
                    CustomScrollView(
                      shrinkWrap: true,
                      slivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index.isEven) {
                                final pageImage = pages[index ~/ 2];
                                return Container(
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.height - 200, // 화면 높이에 맞춤
                                  child: Image.memory(
                                    pageImage.bytes,
                                    fit: BoxFit.cover, // 이미지를 전체 화면에 맞춤
                                  ),
                                );
                              } else {
                                final pageIndex = (index ~/ 2) + 1;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    pageTexts[pageIndex] ?? '페이지 $pageIndex의 텍스트가 없습니다.',
                                    style: const TextStyle(
                                      color: Color(0xFF414141),
                                      fontSize: 16,
                                      fontFamily: 'DM Sans',
                                    ),
                                  ),
                                );
                              }
                            },
                            childCount: pages.length * 2,
                          ),
                        ),
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Container(),
                        ),
                      ],
                    ),
                  if ((widget.lectureName.endsWith('.png') ||
                      widget.lectureName.endsWith('.jpg') ||
                      widget.lectureName.endsWith('.jpeg')) &&
                      imageData != null)
                    Column(
                      children: [
                        Image.memory(
                          imageData!,
                          fit: BoxFit.cover, // 이미지를 전체 화면에 맞춤
                          width: double.infinity,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            pageTexts[1] ?? '이미지의 텍스트가 없습니다.',
                            style: const TextStyle(
                              color: Color(0xFF414141),
                              fontSize: 16,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
      bottomNavigationBar:
          buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}
