// lib/admin/master/models/merk.dart

class Merk {
  final int id; // <-- BERUBAH: int
  final String name;
  // final TypeEngine typeEngine; <-- DIHAPUS (Independen)
  final DateTime createdAt;
  final DateTime updatedAt;

  Merk({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Merk.fromJson(Map<String, dynamic> json) {
    return Merk(
      id: json['id'] as int, // Parse as int
      name: json['merk'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
