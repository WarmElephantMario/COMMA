import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdfx/pdfx.dart'; // PDF 렌더링 패키지 추가
import 'package:http/http.dart' as http; // HTTP 패키지 추가
import '60prepare.dart';
import 'components.dart';
import 'api/api.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:charset_converter/charset_converter.dart';

class ColonPage extends StatefulWidget {
  final String folderName; // 폴더 이름 가져오기 사용
  final String noteName; // 노트 이름 추가
  final String lectureName; // 강의 자료 이름 추가
  final dynamic createdAt; // 생성 날짜 및 시간 추가
  final String? fileUrl; // 강의자료 추가, 선택 사항으로 만듦
  final int? colonFileId;

  const ColonPage({
    Key? key,
    required this.folderName,
    required this.noteName,
    required this.lectureName,
    required this.createdAt,
    this.fileUrl,
    this.colonFileId,
  }) : super(key: key);

  @override
  _ColonPageState createState() => _ColonPageState();
}

class _ColonPageState extends State<ColonPage> {
  bool isLoading = true;
  List<PdfPageImage> pages = [];
  Uint8List? imageData;
  int _selectedIndex = 2;
  Map<int, String> pageScripts = {};
  late int colonFileId;

  @override
  void initState() {
    super.initState();
    if (widget.colonFileId != null) {
      colonFileId = widget.colonFileId!;
      _loadFile();
      _loadPageScripts();
    } else {
      setState(() {
        isLoading = false;
      });
      print('Error: colonFileId is null.');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<Map<int, String>> fetchPageScripts(int colonFileId) async {
  final apiUrl = '${API.baseUrl}/api/get-page-scripts?colonfile_id=$colonFileId';

  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    // 응답 데이터 직접 확인
    print('Response body: ${response.body}');
    final List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
    Map<int, String> pageScripts = {};
    for (var script in jsonResponse) {
      int page = script['page'];
      String url = script['url'];
      pageScripts[page] = url;
    }
    return pageScripts;
  } else {
    throw Exception('Failed to load page scripts');
  }
}


  Future<void> _loadPageScripts() async {
    try {
      pageScripts = await fetchPageScripts(colonFileId);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Failed to load page scripts: $e');
      setState(() {
        isLoading = false;
      });
    }
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
                          _formatDate(
                              widget.createdAt), // 데이터베이스에서 가져온 생성 날짜 및 시간 사용
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
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: pages.length * 2,
                      itemBuilder: (context, index) {
                        if (index.isEven) {
                          final pageImage = pages[index ~/ 2];
                          return Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height -
                                200, // 화면 높이에 맞춤
                            child: Image.memory(
                              pageImage.bytes,
                              fit: BoxFit.cover, // 이미지를 전체 화면에 맞춤
                            ),
                          );
                        } else {
                          final pageIndex = (index ~/ 2);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: FutureBuilder<String>(
                              future: _fetchPageText(pageIndex),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return Text(
                                    snapshot.data ?? '페이지 $pageIndex의 텍스트가 없습니다.',
                                    style: const TextStyle(
                                      color: Color(0xFF414141),
                                      fontSize: 16,
                                      fontFamily: 'DM Sans',
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        }
                      },
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
                          child: FutureBuilder<String>(
                            future: _fetchPageText(0),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return Text(
                                  snapshot.data ?? '이미지의 텍스트가 없습니다.',
                                  style: const TextStyle(
                                    color: Color(0xFF414141),
                                    fontSize: 16,
                                    fontFamily: 'DM Sans',
                                  ),
                                );
                              }
                            },
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



Future<String> _fetchPageText(int pageIndex) async {
  int pageNumber = pageIndex;
  if (pageScripts.containsKey(pageNumber)) {
    final url = pageScripts[pageNumber]!;
    print('Fetching text from URL: $url');  // URL 출력
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        try {
          // UTF-8로 시도
          final text = utf8.decode(response.bodyBytes);
          print('Loaded text for page $pageNumber: $text');  // 로드된 텍스트 출력
          return text;
        } catch (e) {
          print('Error decoding text as UTF-8 for page $pageNumber: $e');
          try {
            // EUC-KR로 수동으로 디코딩
            final eucKrBytes = response.bodyBytes;
            final text = eucKrBytes.map((e) => e & 0xFF).map((e) => e.toRadixString(16)).join(' ');
            print('Loaded text with manual EUC-KR decoding for page $pageNumber: $text');
            return text;
          } catch (e) {
            print('Error decoding text with manual EUC-KR decoding for page $pageNumber: $e');
            return 'Error decoding page text';
          }
        }
      } else {
        print('Failed to load page text: ${response.statusCode}');
        return 'Failed to load page text';
      }
    } catch (e) {
      print('Error loading page text: $e');
      return 'Error loading page text';
    }
  } else {
    return '페이지 $pageNumber의 텍스트가 없습니다.';
  }
}
}