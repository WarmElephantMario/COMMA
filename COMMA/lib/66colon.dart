import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import '60prepare.dart';
import 'components.dart';
import 'api/api.dart';
import 'dart:typed_data';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:charset_converter/charset_converter.dart';

class ColonPage extends StatefulWidget {
  final String folderName;
  final String noteName;
  final String lectureName;
  final dynamic createdAt;
  final String? fileUrl;
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
  Map<int, List<String>> pageScripts = {}; // 페이지별 텍스트를 저장할 Map
  Map<int, String> pageTexts = {}; // 페이지별 대체 텍스트를 저장할 Map
  final Set<int> _blurredPages = {}; // 블러 처리된 페이지를 추적하는 Set
  late int colonFileId;
  int type = -1; // colonDetails에서 type을 가져와 저장할 변수
  //Texts가 붙으면 대체텍스트
  //Scripts가 붙으면 자막

  @override
  void initState() {
    super.initState();
    if (widget.colonFileId != null) {
      colonFileId = widget.colonFileId!;
      _loadFile();
      _loadPageScripts();
      _loadAltTableUrl(); // Alt_table URL 로드
      _fetchColonType(); // 콜론 타입 로드
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

  Future<void> _loadAltTableUrl() async {
    try {
      String url = await _fetchAltTableUrl(colonFileId);
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final textLines = utf8.decode(response.bodyBytes).split('//');
        setState(() {
          pageTexts = {
            for (int i = 0; i < textLines.length; i++) i + 1: textLines[i]
          };
        });
      } else {
        print('Failed to fetch text file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading alternative text URL: $e');
    }
  }

  Future<void> _fetchColonType() async {
    try {
      Map<String, dynamic> colonDetails = await _fetchColonDetails(colonFileId);
      setState(() {
        type = colonDetails['type'];
      });
    } catch (e) {
      print('Error fetching colon details: $e');
    }
  }

  Future<Map<int, List<String>>> fetchPageScripts(int colonFileId) async {
    final apiUrl =
        '${API.baseUrl}/api/get-page-scripts?colonfile_id=$colonFileId';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse =
          jsonDecode(utf8.decode(response.bodyBytes));
      Map<int, List<String>> pageScripts = {};
      for (var script in jsonResponse) {
        int page = script['page'];
        String url = script['record_url'];
        if (!pageScripts.containsKey(page)) {
          pageScripts[page] = [];
        }
        pageScripts[page]?.add(url);
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

  void _toggleBlur(int page) {
    setState(() {
      if (_blurredPages.contains(page)) {
        _blurredPages.remove(page);
      } else {
        _blurredPages.add(page);
      }
    });
  }

  // Alt_table의 특정 colonfile_id 행에서 URL 가져오기
  Future<String> _fetchAltTableUrl(int colonFileId) async {
    var url = '${API.baseUrl}/api/get-alt-url/$colonFileId';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return jsonResponse['alternative_text_url'];
    } else {
      throw Exception('Failed to load alternative text URL');
    }
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
                          final pageIndex = index ~/ 2;
                          final pageImage = pages[pageIndex];
                          return GestureDetector(
                            onTap: () {
                              if (type == 0) {
                                _toggleBlur(pageIndex + 1);
                              }
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.height -
                                      200, // 화면 높이에 맞춤
                                  child: Image.memory(
                                    pageImage.bytes,
                                    // 수정
                                    //fit: BoxFit.cover, // 이미지를 전체 화면에 맞춤
                                  ),
                                ),
                                if (_blurredPages.contains(pageIndex + 1) &&
                                    type == 0)
                                  Container(
                                    width: double.infinity,
                                    height: MediaQuery.of(context).size.height -
                                        200, // 화면 높이에 맞춤
                                    color: Colors.black.withOpacity(0.5),
                                    child: Center(
                                      child: Text(
                                        pageTexts[pageIndex + 1] ??
                                            '텍스트가 없습니다.',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'DM Sans',
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        } else {
                          final pageIndex = index ~/ 2;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: FutureBuilder<List<String>>(
                              future: _fetchPageTexts(pageIndex),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  final pageTexts = snapshot.data ?? [];
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: pageTexts.map((text) {
                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 10, 20, 10),
                                        child: Text(
                                          text,
                                          style: TextStyle(
                                              color: Color(0xFF414141),
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500,
                                              height: 1.8,
                                              fontFamily:
                                                  GoogleFonts.ibmPlexSansKr()
                                                      .fontFamily),
                                        ),
                                      );
                                    }).toList(),
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
                        GestureDetector(
                          onTap: () {
                            if (type == 0) {
                              _toggleBlur(1);
                            }
                          },
                          child: Stack(
                            children: [
                              Image.memory(
                                imageData!,
                                fit: BoxFit.cover, // 이미지를 전체 화면에 맞춤
                                width: double.infinity,
                              ),
                              if (_blurredPages.contains(1) && type == 0)
                                Container(
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.height -
                                      200, // 화면 높이에 맞춤
                                  color: Colors.black.withOpacity(0.5),
                                  child: Center(
                                    child: Text(
                                      pageTexts[1] ?? '이미지의 텍스트가 없습니다.',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'DM Sans',
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: FutureBuilder<List<String>>(
                            future: _fetchPageTexts(0), // 이미지 파일은 1 페이지로 간주
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                final pageTexts = snapshot.data ?? [];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: pageTexts.map((text) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        text,
                                        style: const TextStyle(
                                          color: Color(0xFF414141),
                                          fontSize: 16,
                                          fontFamily: 'DM Sans',
                                        ),
                                      ),
                                    );
                                  }).toList(),
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

//대체 텍스트
  Future<List<String>> _fetchPageTexts(int pageIndex) async {
    if (pageScripts.containsKey(pageIndex)) {
      final urls = pageScripts[pageIndex]!;
      List<String> texts = [];
      for (var url in urls) {
        print('Fetching text from URL: $url'); // URL 출력
        try {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            try {
              // UTF-8로 시도
              final text = utf8.decode(response.bodyBytes);
              print('Loaded text for page $pageIndex: $text'); // 로드된 텍스트 출력
              texts.add(text);
            } catch (e) {
              print('Error decoding text as UTF-8 for page $pageIndex: $e');
              try {
                // EUC-KR로 수동으로 디코딩
                final eucKrBytes = response.bodyBytes;
                final text = eucKrBytes
                    .map((e) => e & 0xFF)
                    .map((e) => e.toRadixString(16))
                    .join(' ');
                print(
                    'Loaded text with manual EUC-KR decoding for page $pageIndex: $text');
                texts.add(text);
              } catch (e) {
                print(
                    'Error decoding text with manual EUC-KR decoding for page $pageIndex: $e');
                texts.add('Error decoding page text');
              }
            }
          } else {
            print('Failed to load page text: ${response.statusCode}');
            texts.add('Failed to load page text');
          }
        } catch (e) {
          print('Error loading page text: $e');
          texts.add('Error loading page text');
        }
      }
      return texts;
    } else {
      return ['페이지 ${pageIndex + 1}의 텍스트가 없습니다.'];
    }
  }
}
