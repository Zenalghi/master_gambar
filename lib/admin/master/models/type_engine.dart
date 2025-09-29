// Model spesifik untuk Type Engine yang menyertakan timestamps
class TypeEngine {
  final String id;
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
      id: json['id'],
      name: json['type_engine'], // Sesuaikan dengan key dari backend
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
