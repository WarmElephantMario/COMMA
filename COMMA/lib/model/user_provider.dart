import 'package:flutter/material.dart';
import 'user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoggedIn = false;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;

  void setUser(User user) {
    _user = user;
    _isLoggedIn = true;
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

  void logIn(User user) {
    _user = user;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logOut() {
    _isLoggedIn = false;
    _user = null;
    notifyListeners();
  }
}
