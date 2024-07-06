import 'package:flutter/material.dart';
import 'components.dart';
import '8_verification3.dart';

// class FigmaToCodeApp extends StatelessWidget {
//   const FigmaToCodeApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData.dark().copyWith(
//         scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
//       ),
//       home: Verification_screen(),
//     );
//   }
// }


class Verification_write_screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
          icon: Icon(
            Icons.arrow_back,
            color: Color(0xFF36AE92),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 0),
        children: [
          Information(),
        ],
      ),
    );
  }
}

class Information extends StatelessWidget {
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
              SizedBox(height: size.height * 0.10),
              Text(
                '인증코드',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                '계정 생성에 사용한 이메일 주소로\n인증코드가 발송되었습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF245B3A),
                  fontSize: 14,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: size.height * 0.07),
              InputButton(
                label: '인증코드를 입력해주세요',
                keyboardType: TextInputType.emailAddress,
                controller: TextEditingController(),
              ),
              SizedBox(height: size.height * 0.07),

              ClickButton(
                text: '인증 완료하기',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Verification_Complete_screen()));
                },
              ),

              SizedBox(height: 200),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '이미 계정이 있으신가요?',
                    style: TextStyle(
                      color: Color(0xFF36AE92),
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w500,
                      height: 0.11,
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      // TODO: 로그인 화면으로 네비게이션 코드 추가
                      print('로그인 버튼이 클릭되었습니다.');
                    },
                    child: Text(
                      '로그인',
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
        ],
      ),
    );
  }
}
