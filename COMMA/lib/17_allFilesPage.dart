import 'package:flutter/material.dart';
import 'api/api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AllFilesPage extends StatefulWidget {
  final int userKey;
  final String fileType;

  const AllFilesPage({
    super.key,
    required this.userKey,
    required this.fileType,
  });

  @override
  _AllFilesPageState createState() => _AllFilesPageState();
}

class _AllFilesPageState extends State<AllFilesPage> {
  List<Map<String, dynamic>> files = [];

  @override
  void initState() {
    super.initState();
    fetchFiles();
  }

  Future<void> fetchFiles() async {
    final response = await http.get(Uri.parse(
        '${API.baseUrl}/api/get${widget.fileType == 'lecture' ? 'Lecture' : 'Colon'}Files/${widget.userKey}'));

    if (response.statusCode == 200) {
      setState(() {
        files =
            List<Map<String, dynamic>>.from(jsonDecode(response.body)['files']);
      });
    } else {
      throw Exception('Failed to load files');
    }
  }

  String formatDateTimeToKorean(String dateTime) {
    if (dateTime.isEmpty) return 'Unknown';
    final DateTime utcDateTime = DateTime.parse(dateTime);
    final DateTime koreanDateTime = utcDateTime.add(const Duration(hours: 9));
    return DateFormat('yyyy/MM/dd HH:mm').format(koreanDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileType == 'lecture' ? '전체 강의 파일' : '전체 콜론 파일'),
      ),
      body: files.isEmpty
          ? const Center(child: Text('파일이 없습니다.'))
          : ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return ListTile(
                  title: Text(file['file_name']),
                  subtitle: Text(formatDateTimeToKorean(file['created_at'])),
                  onTap: () {
                    // 파일을 클릭했을 때의 동작
                    print('File ${file['file_name']} is clicked');
                  },
                );
              },
            ),
    );
  }
}
