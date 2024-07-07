import 'package:flutter/material.dart';
import 'components.dart';
import '14_homepage_search_result.dart';
import 'api/api.dart';
import 'model/user.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  final User userInfo;

  const MainPage({Key? key, required this.userInfo}) : super(key: key);

  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<dynamic> lectureFolders = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchLectureFolders();
  }

  Future<void> fetchLectureFolders() async {
    final response = await http.get(Uri.parse(API.getAllFolders));

    if (response.statusCode == 200) {
      setState(() {
        lectureFolders = jsonDecode(response.body)['folders'];
      });
    } else {
      throw Exception('Failed to load lecture folders');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        iconTheme: const IconThemeData(
          color: Color(0xFF36AE92),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search_rounded,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchingScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                //'안녕하세요, 이화연 님',
                '안녕하세요, ${widget.userInfo.user_email} 님',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '최근에 학습한 강의 파일이에요.',
                    style: TextStyle(
                      color: Color(0xFF575757),
                      fontSize: 13,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print('view all button is clicked');
                    },
                    child: const Row(
                      children: [
                        Text(
                          '전체 보기',
                          style: TextStyle(
                            color: Color(0xFF36AE92),
                            fontSize: 12,
                            fontFamily: 'Mulish',
                            fontWeight: FontWeight.w800,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: Color(0xFF36AE92),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Fetch된 데이터를 사용하여 LectureExample 위젯을 동적으로 생성
              ...(
                lectureFolders.isEmpty
                    ? [
                        const Text(
                          '최근에 학습한 강의 자료가 없어요.',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                          ),
                        )
                      ]
                    : lectureFolders.take(3) // 상위 3개의 폴더만 가져옴
                        .map((folder) {
                        return GestureDetector(
                          onTap: () {
                            print('Lecture ${folder['lecture_name']} is clicked');
                          },
                          child: LectureExample(
                            lectureName: folder['lecture_name'],
                            date: folder['lecture_date'],
                          ),
                        );
                      }).toList()
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '최근에 학습한 콜론 파일이에요.',
                    style: TextStyle(
                      color: Color(0xFF575757),
                      fontSize: 13,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print('view all2 button is clicked');
                    },
                    child: const Row(
                      children: [
                        Text(
                          '전체 보기',
                          style: TextStyle(
                            color: Color(0xFF36AE92),
                            fontSize: 12,
                            fontFamily: 'Mulish',
                            fontWeight: FontWeight.w800,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: Color(0xFF36AE92),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  print('certain lecture is clicked');
                },
                child: const LectureExample(
                  lectureName: '정보통신공학',
                  date: '2024/06/07',
                ),
              ),
              GestureDetector(
                onTap: () {
                  print('certain lecture is clicked');
                },
                child: const LectureExample(
                  lectureName: '컴퓨터알고리즘',
                  date: '2024/06/10',
                ),
              ),
              GestureDetector(
                onTap: () {
                  print('certain lecture is clicked');
                },
                child: const LectureExample(
                  lectureName: '데이터베이스',
                  date: '2024/06/15',
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}

