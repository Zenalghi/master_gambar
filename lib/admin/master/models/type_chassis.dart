// File: lib/admin/master/models/type_chassis.dart

class TypeChassis {
  final int id; // <-- BERUBAH: int
  final String name;
  // final Merk merk; <-- DIHAPUS (Independen)
  final DateTime createdAt;
  final DateTime updatedAt;

  TypeChassis({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TypeChassis.fromJson(Map<String, dynamic> json) {
    return TypeChassis(
      id: json['id'] as int, // Parse as int
      name: json['type_chassis'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
