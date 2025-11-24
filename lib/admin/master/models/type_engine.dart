// lib/admin/master/models/type_engine.dart

class TypeEngine {
  final int id; // <-- BERUBAH dari String ke int
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  TypeEngine({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TypeEngine.fromJson(Map<String, dynamic> json) {
    return TypeEngine(
      id: json['id'] as int, // <-- Pastikan di-parse sebagai int
      name: json['type_engine'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
