class User {
  int userKey;  // int -> String으로 변경
  String userId; 
  String user_nickname;

  User(this.userKey, this.userId, this.user_nickname);

  factory User.fromJson(Map<String, dynamic> json) => User(
        json['userKey'],
        json['userId'],
        json['user_nickname'],
      );

  Map<String, dynamic> toJson() => {
        'userKey' : userKey,  // toString() 필요 없음
        'userId' : userId, 
        'user_nickname': user_nickname,
      };
}
