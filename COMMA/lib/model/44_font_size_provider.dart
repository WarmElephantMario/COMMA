import 'package:flutter/material.dart';

class FontSizeProvider with ChangeNotifier {
  double _scaleFactor = 1.0; // 기본 비율 (1.0 = 보통 크기)

  double get scaleFactor => _scaleFactor;

  void setFontSize(double scaleFactor) {
    _scaleFactor = scaleFactor; // 사용자가 선택한 비율을 설정
    notifyListeners(); // 변경 사항 알리기
  }
}
