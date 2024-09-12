class User {
  int userKey; // int -> String으로 변경
  String userId;
  String user_nickname;
  int? dis_type;

  User(this.userKey, this.userId, this.user_nickname, this.dis_type);

  factory User.fromJson(Map<String, dynamic> json) => User(
      json['userKey'], json['userId'], json['user_nickname'], json['dis_type']);

  Map<String, dynamic> toJson() => {
        'userKey': userKey, // toString() 필요 없음
        'userId': userId,
        'user_nickname': user_nickname,
        'dis_type': dis_type
      };
}
