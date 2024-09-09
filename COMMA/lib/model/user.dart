class User {
  String userKey;  // int -> String으로 변경
  String user_nickname;

  User(this.userKey, this.user_nickname);

  factory User.fromJson(Map<String, dynamic> json) => User(
        json['userKey'],
        json['user_nickname'],
      );

  Map<String, dynamic> toJson() => {
        'userKey' : userKey,  // toString() 필요 없음
        'user_nickname': user_nickname,
      };
}
