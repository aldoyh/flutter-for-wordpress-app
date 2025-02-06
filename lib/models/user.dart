class User {
  final int id;
  final String username;
  final String email;
  final String token;
  final String displayName;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.token,
    required this.displayName,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      token: json['token'] as String,
      displayName: json['name'] as String,
      avatarUrl: json['avatar_urls']?['96'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'token': token,
    'name': displayName,
    'avatar_urls': avatarUrl != null ? {'96': avatarUrl} : null,
  };

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? token,
    String? displayName,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      token: token ?? this.token,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  String toString() => 'User(id: $id, username: $username, email: $email)';
}