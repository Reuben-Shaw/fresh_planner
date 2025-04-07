class User {
  final String email, username, password;

  User({
    required this.email,
    required this.username,
    required this.password,
  });

  Map<String, Object?> toMap() {
    return {
      'email': email,
      'username': username,
      'password': password,
    };
  }

  @override
  String toString() {
    return 'User{email: $email, username: $username, password: $password}';
  }
}
