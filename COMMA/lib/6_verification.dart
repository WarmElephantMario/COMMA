import 'package:flutter/material.dart';
import '7_verification2.dart';
import 'components.dart';

class Verification_screen extends StatelessWidget {
  final String userEmail; // 추가된 부분
  final String userId; // 추가된 부분
  final String userPassword; // 추가된 부분

  const Verification_screen({
    super.key,
    required this.userEmail, // 추가된 부분
    required this.userId, // 추가된 부분
    required this.userPassword, // 추가된 부분
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF36AE92),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 0),
        children: [
          Information(
            userEmail: userEmail, // 추가된 부분
            userId: userId, // 추가된 부분
            userPassword: userPassword, // 추가된 부분
          ),
        ],
      ),
    );
  }
}

class Information extends StatelessWidget {
  final String userEmail; // 추가된 부분
  final String userId; // 추가된 부분
  final String userPassword; // 추가된 부분

  const Information({
    super.key,
    required this.userEmail, // 추가된 부분
    required this.userId, // 추가된 부분
    required this.userPassword, // 추가된 부분
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      color: Colors.white,
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: size.height * 0.15),
              SizedBox(
                width: size.width,
                height: size.height * 0.2,
                child: Image.asset('assets/signup.png'),
              ),
              SizedBox(height: size.height * 0.01),
              const Text(
                '인증코드를 이메일로\n전송했습니다!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: size.height * 0.07),
              ClickButton(
                text: '인증코드 입력하기',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Verification_write_screen(
                        userEmail: userEmail, // 추가된 부분
                        userId: userId, // 추가된 부분
                        userPassword: userPassword, // 추가된 부분
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 200),
              const Text(
                '인증코드가 전송되지 않았나요?',
                style: TextStyle(
                  color: Color(0xFF36AE92),
                  fontSize: 14,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                  height: 0.11,
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  print('코드 재전송 버튼이 클릭되었습니다.');
                },
                child: const Text(
                  '코드 재전송',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
