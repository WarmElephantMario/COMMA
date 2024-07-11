import 'package:flutter/material.dart';
import '7_verification2.dart';
import 'components.dart';

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

class Verification_screen extends StatelessWidget {
  const Verification_screen({super.key});

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
        children: const [
          Information(),
        ],
      ),
    );
  }
}

class Information extends StatelessWidget {
  const Information({super.key});

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
                        builder: (context) => Verification_write_screen()),
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
