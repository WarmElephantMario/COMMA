import 'dart:convert';
import 'package:http/http.dart' as http;

class DBHelper {
  static Future<List<String>> getFolders(String type) async {
    final response =
        await http.get(Uri.parse('http://10.240.45.217:3000/folders/$type'));
    // 본인 ip 주소로 바꾸세요 → http://본인노트북ip:3000/folders/$type

    if (response.statusCode == 200) {
      List<dynamic> folders = json.decode(response.body);
      return folders.map((folder) => folder['name'] as String).toList();
    } else {
      throw Exception('Failed to load folders');
    }
  }
}
