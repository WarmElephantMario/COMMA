class User {
  int userKey;
  String user_id;
  String user_email;
  String user_password;
  String user_nickname;

  User(this.userKey, this.user_id, this.user_email, this.user_password, this.user_nickname);

  factory User.fromJson(Map<String, dynamic> json) => User(
        json['userKey'],
        json['user_id'],
        json['user_email'],
        json['user_password'],
        json['user_nickname'],
      );

  Map<String, dynamic> toJson() => {
        'userKey' : userKey.toString(),
        'user_id': user_id,
        'user_email': user_email,
        'user_password': user_password,
        'user_nickname': user_nickname,
      };
}
