import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizePage extends StatefulWidget {
  const FontSizePage({Key? key}) : super(key: key);

  @override
  _FontSizePageState createState() => _FontSizePageState();
}

class _FontSizePageState extends State<FontSizePage> {
  double scaleFactor = 1.0;
  final FontSizeManager _fontSizeManager = FontSizeManager();

  @override
  void initState() {
    super.initState();
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    double fontSize = await _fontSizeManager.getFontSize();
    setState(() {
      scaleFactor = fontSize;
    });
  }

  void _setFontSize(double value) {
    setState(() {
      scaleFactor = value;
      _fontSizeManager.setFontSize(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // 텍스트 크기를 화면 너비와 사용자가 설정한 비율에 맞추어 조정
    final textFontSize = screenWidth * 0.05 * scaleFactor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.colorScheme.onTertiary),
        title: Text(
          '글씨 크기 조정',
          style: TextStyle(
            color: theme.colorScheme.onTertiary,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w600,
            fontSize: textFontSize, // 반응형으로 설정된 텍스트 크기
          ),
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
              style: TextStyle(
                color: theme.colorScheme.onTertiary,
                fontSize: textFontSize, // 반응형으로 설정된 텍스트 크기
              ),
            ),
          ),
          const SizedBox(height: 100),
          ListTile(
            title: Text(
              '보통',
              style: TextStyle(
                color: theme.colorScheme.onTertiary,
                fontSize: textFontSize * 0.8, // 보통 텍스트 크기
              ),
            ),
            leading: Radio<double>(
              value: 1.0,
              groupValue: scaleFactor,
              onChanged: (double? value) {
                if (value != null) _setFontSize(value);
              },
            ),
          ),
          ListTile(
            title: Text(
              '크게',
              style: TextStyle(
                color: theme.colorScheme.onTertiary,
                fontSize: textFontSize * 1.0, // 크게 텍스트 크기
              ),
            ),
            leading: Radio<double>(
              value: 1.3,
              groupValue: scaleFactor,
              onChanged: (double? value) {
                if (value != null) _setFontSize(value);
              },
            ),
          ),
          ListTile(
            title: Text(
              '엄청 크게',
              style: TextStyle(
                color: theme.colorScheme.onTertiary,
                fontSize: textFontSize * 1.2, // 엄청 크게 텍스트 크기
              ),
            ),
            leading: Radio<double>(
              value: 1.5,
              groupValue: scaleFactor,
              onChanged: (double? value) {
                if (value != null) _setFontSize(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FontSizeManager {
  static const String _fontSizeKey = 'fontSize';

  Future<void> setFontSize(double fontSize) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, fontSize);
  }

  Future<double> getFontSize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? 1.0; // 기본값 1.0
  }
}
