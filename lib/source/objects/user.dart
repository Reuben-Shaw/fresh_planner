class User {
  final String email, username;
  final String? password, uid;

  User({
    required this.email,
    required this.username,
    this.password,
    this.uid,
  });

  Map<String, Object?> toMap() {
    return {
      'email': email,
      'username': username,
      'password': password,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      username: json['username'],
      password: json['password'],
      uid: json['uid'],
    );
  }

  @override
  String toString() {
    return 'User{email: $email, username: $username, password: $password, uid: $uid}';
  }
}
