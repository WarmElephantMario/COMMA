import 'package:flutter/material.dart';
import 'components.dart';
import 'api/api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // 날짜 포맷을 위해 추가

class MainToSearchPage extends StatefulWidget {
  const MainToSearchPage({super.key});

  @override
  _MainToSearchPageState createState() => _MainToSearchPageState();
}

class _MainToSearchPageState extends State<MainToSearchPage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> searchResults = [];
  final TextEditingController _searchController = TextEditingController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> searchFiles(String query) async {
    final response = await http
        .get(Uri.parse('${API.baseUrl}/api/searchFiles?query=$query'));

    if (response.statusCode == 200) {
      setState(() {
        searchResults =
            List<Map<String, dynamic>>.from(jsonDecode(response.body)['files']);
      });
    } else {
      throw Exception('Failed to search files');
    }
  }

  String formatDateTimeToKorean(String dateTime) {
    if (dateTime.isEmpty) return 'Unknown';
    final DateTime utcDateTime = DateTime.parse(dateTime);
    final DateTime koreanDateTime = utcDateTime.add(const Duration(hours: 9));
    return DateFormat('yyyy/MM/dd HH:mm').format(koreanDateTime);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 45,
                child: TextField(
                  style: TextStyle(color: Colors.grey[800]),
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromRGBO(228, 240, 231, 100),
                    hintText: '검색할 파일명을 입력하세요.',
                    hintStyle: const TextStyle(
                      color: Color(0xFF36AE92),
                      fontSize: 15,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF36AE92),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                searchFiles(_searchController.text);
              },
              style: ElevatedButton.styleFrom(
                iconColor: const Color(0xFF36AE92),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('검색'),
            ),
          ],
        ),
      ),
      body: searchResults.isEmpty
          ? const SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(50.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '최근 검색 내역이 없어요.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final file = searchResults[index];
                return ListTile(
                  title: Text(
                    file['file_name'],
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                  subtitle: Text(formatDateTimeToKorean(file['created_at']),
                      style: TextStyle(color: Colors.grey[700])),
                  onTap: () {
                    print('File ${file['file_name']} is clicked');
                  },
                );
              },
            ),
      bottomNavigationBar:
          buildBottomNavigationBar(context, _selectedIndex, _onItemTapped),
    );
  }
}