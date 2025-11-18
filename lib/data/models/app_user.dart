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
  final String? hint;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppUser({
    required this.id,
    required this.name,
    required this.username,
    this.role,
    this.signature,
    this.hint,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
      signature: json['signature'],
      hint: json['hint'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
