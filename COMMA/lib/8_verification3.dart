import 'package:flutter/material.dart';
import 'components.dart';
import '9_signin.dart';

class Verification_Complete_screen extends StatelessWidget {
  const Verification_Complete_screen({super.key});

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
              SizedBox(height: size.height * 0.10),
              SizedBox(
                width: size.width,
                height: size.height * 0.2,
                child: Image.asset('assets/verify_success.png'),
              ),
              const Text(
                '인증 성공!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: size.height * 0.13),
              ClickButton(
                text: '로그인하기',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SigninPage()));
                },
              ),
              const SizedBox(height: 200),
            ],
          ),
        ],
      ),
    );
  }
}
