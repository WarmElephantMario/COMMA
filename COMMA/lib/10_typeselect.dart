import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '16_homepage_move.dart';
import 'model/user_provider.dart';
import 'package:http/http.dart' as http;
import 'api/api.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

class DisabilitySelectionPage extends StatelessWidget {
  const DisabilitySelectionPage({Key? key}) : super(key: key);

  // 장애 유형을 저장하는 함수 (0: 시각장애인용, 1: 청각장애인용)
  Future<void> _setDisabilityType(int type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dis_type', type);
  }

  // DB에 학습 유형 저장
// DB에 학습 유형 저장
  Future<void> _saveDisabilityTypeToDB(
      int userKey, int type, UserProvider userProvider) async {
    try {
      final response = await http.post(
        Uri.parse('${API.baseUrl}/api/user/$userKey/update-type'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, int?>{
          'type': type,
        }),
      );

      // 상태 코드와 응답 내용 로그 출력
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // 응답이 200일 경우에만 처리
      if (response.statusCode == 200) {
        print('학습 유형이 DB에 저장되었습니다.');
        // UserProvider에 저장된 학습 유형 업데이트
        userProvider.updateDisType(type);
      } else {
        throw Exception('DB에 학습 유형을 저장하는 데 실패했습니다.');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('DB에 학습 유형을 저장하는 데 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('학습 유형 선택'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '사용할 학습 유형을 선택하세요',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);

                print('사용자 키: ${userProvider.user!.userKey}');

                // 시각장애인용 모드 선택 후 저장
                await _setDisabilityType(0); // 시각장애인용 모드

                // DB에 학습 유형 저장
                await _saveDisabilityTypeToDB(
                    userProvider.user!.userKey, 0, userProvider);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                '시각 장애인용 모드 (대체 텍스트)',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);

                print('사용자 키: ${userProvider.user!.userKey}');

                // 청각장애인용 모드 선택 후 저장
                await _setDisabilityType(1); // 청각장애인용 모드

                // DB에 학습 유형 저장
                await _saveDisabilityTypeToDB(
                    userProvider.user!.userKey, 1, userProvider);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                '청각 장애인용 모드 (실시간 자막)',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
