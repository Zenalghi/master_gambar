class User {
  final int id;
  final String name;
  final String username;
  final String role;

  User({required this.id, required this.name, required this.username, required this.role});

  // Factory constructor untuk membuat User dari JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      role: json['role'],
    );
  }
}