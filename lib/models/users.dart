class Users {
  final int? id;
  final String username;
  final String password;
  final String role;

  Users({this.id, required this.username, required this.password, required this.role});

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'password': password,
    'role': role
  };

  factory Users.fromMap(Map<String, dynamic> map) => Users(
    id: map['id'],
    username: map['username'],
    password: map['password'],
    role: map['role']
  );

  Users copyWith({
    int? id,
    String? username,
    String? password,
    String? role
  }) {
    return Users(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role
    );
  }
}