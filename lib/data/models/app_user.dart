// Model untuk object Role yang ada di dalam AppUser
class Role {
  final int id;
  final String name;

  Role({required this.id, required this.name});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(id: json['id'], name: json['name']);
  }
}

// Model utama untuk data User
class AppUser {
  final int id;
  final String name;
  final String username;
  final Role? role;
  final String? signature;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppUser({
    required this.id,
    required this.name,
    required this.username,
    this.role,
    this.signature,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      role: json['roles'] != null ? Role.fromJson(json['roles']) : null,
      signature: json['signature'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
