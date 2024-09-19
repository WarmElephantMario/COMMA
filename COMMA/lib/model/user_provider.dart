import 'package:flutter/material.dart';
import 'user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoggedIn = false;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;

  // Setter for user object
  void setUser(User user) {
    _user = user;
    _isLoggedIn = true;
    notifyListeners();
  }

  // 닉네임 업데이트
  void updateUserNickname(String newNickname) {
    if (_user != null) {
      _user = User(_user!.userKey, _user!.userId, newNickname, null);
      notifyListeners();

    }
  }

  // 타입 업데이트
  void updateDisType(int disType) {
    if (_user != null) {
      _user =
          User(_user!.userKey, _user!.userId, _user!.user_nickname, disType);
      notifyListeners();
    }
  }

//  // 회원탈퇴 시 UserKey 기록을 Provider에서 삭제
//   void setUserKeytoNULL() {
//     if (_user != null) {
//       _user = User(
//           null,
//           _user!.userId, 
//           _user!.user_nickname,
//           null);
//     } else {
//       _user = User(
//           null,
//           _user!.userId, // int.parse() 제거, 바로 userId 사용
//           'New User', // 기본 닉네임 설정
//           null);
//     }
//     _isLoggedIn = true;
//     notifyListeners();
//   }

  // 로그아웃
  void logOut() {
    _isLoggedIn = false;
    _user = null;
    notifyListeners();
  }
}