import 'package:flutter/material.dart';
import '7_verification2.dart';

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

class ClickButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ClickButton({Key? key, required this.text, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: size.width * 0.9,
          height: size.height * 0.065,
          decoration: ShapeDecoration(
            color: Color.fromRGBO(54, 174, 146, 1.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Verification_screen extends StatelessWidget {
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
              SizedBox(height: size.height * 0.15),
              Container(
                width: size.width,
                height: size.height * 0.2,
                child: Image.asset('assets/signup.png'),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
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
                   MaterialPageRoute(builder: (context) => Verification_write_screen()),
                  );

                },
              ),
              SizedBox(height: 200),
              Text(
                '인증코드가 전송되지 않았나요?',
                style: TextStyle(
                  color: Color(0xFF36AE92),
                  fontSize: 14,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                  height: 0.11,
                ),
              ),
              SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  print('코드 재전송 버튼이 클릭되었습니다.');
                },
                child: Text(
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

