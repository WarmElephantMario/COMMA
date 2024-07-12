import 'package:flutter/material.dart';
import 'user.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void updateUserNickname(String newNickname) {
    if (_user != null) {
      _user = User(
        _user!.userKey,
        _user!.user_id,
        _user!.user_email,
        _user!.user_password,
        newNickname,
      );
      notifyListeners();
    }
  }
}
