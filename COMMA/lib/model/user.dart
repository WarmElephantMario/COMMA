class User{
  int user_id;
  String user_email;
  String user_phone;
  String user_password;

  User(this.user_id, this.user_email, this.user_phone, this.user_password);

  factory User.fromJson(Map<String, dynamic> json) => User(
      json['user_id'],
      json['user_email'],
      json['user_phone'],
      json['user_password'],
  );

  Map<String, dynamic> toJson() => {
    'user_id' : user_id.toString(),
    'user_phone' : user_phone,
    'user_email' : user_email,
    'user_password' : user_password,
  };
}

