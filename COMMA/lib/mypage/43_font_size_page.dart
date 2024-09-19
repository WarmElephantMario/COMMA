import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/44_font_size_provider.dart';

class FontSizePage extends StatelessWidget {
  const FontSizePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    // 디스플레이 비율을 가져옴
    final scaleFactor = fontSizeProvider.scaleFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '글씨 크기 조정',
          style: TextStyle(
              color: Color.fromARGB(255, 48, 48, 48),
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '원하는 글씨 크기를 선택하세요:',
              style: TextStyle(fontSize: 20 * scaleFactor),
            ),
          ),
          const SizedBox(height: 100),
          ListTile(
            title: const Text('보통'),
            leading: Radio<double>(
              value: 1.0, // 보통 크기 비율 (100%)
              groupValue: fontSizeProvider.scaleFactor,
              activeColor: Colors.teal, // 버튼 색상을 teal로 설정
              onChanged: (double? value) {
                fontSizeProvider.setFontSize(value!);
              },
            ),
          ),
          ListTile(
            title: const Text('크게'),
            leading: Radio<double>(
              value: 1.2, // 크게 비율 (120%)
              groupValue: fontSizeProvider.scaleFactor,
              activeColor: Colors.teal, // 버튼 색상을 teal로 설정
              onChanged: (double? value) {
                fontSizeProvider.setFontSize(value!);
              },
            ),
          ),
          ListTile(
            title: const Text('엄청 크게'),
            leading: Radio<double>(
              value: 1.3, // 엄청 크게 비율 (130%)
              groupValue: fontSizeProvider.scaleFactor,
              activeColor: Colors.teal, // 버튼 색상을 teal로 설정
              onChanged: (double? value) {
                fontSizeProvider.setFontSize(value!);
              },
            ),
          ),
        ],
      ),
    );
  }
}
