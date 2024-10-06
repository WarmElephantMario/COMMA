import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '16_homepage_move.dart';
import 'model/user_provider.dart';
import 'package:http/http.dart' as http;
import 'api/api.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'mypage/44_font_size_page.dart';

class DisabilitySelectionPage extends StatelessWidget {
  const DisabilitySelectionPage({Key? key}) : super(key: key);

  // 장애 유형을 저장하는 함수 (0: 시각장애인용, 1: 청각장애인용)
  Future<void> _setDisabilityType(int type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dis_type', type);
  }

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
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 150),
            Text(
              '사용자 학습 유형을 선택해주세요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              '오늘도\nCOMMA와 함께 힘차게 공부해요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.surfaceBright,
                fontSize: 14,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 100),
            GestureDetector(
              onTap: () async {
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
              child: Container(
                width: size.width * 0.9,
                height: size.height * 0.065,
                decoration: ShapeDecoration(
                  color: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    '시각 장애인용 모드 (대체 텍스트)',
                    style: TextStyle(
                      color: theme.colorScheme.surface,
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
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
              child: Container(
                width: size.width * 0.9,
                height: size.height * 0.065,
                decoration: ShapeDecoration(
                  color: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    '청각 장애인용 모드 (실시간 자막)',
                    style: TextStyle(
                      color: theme.colorScheme.surface,
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
