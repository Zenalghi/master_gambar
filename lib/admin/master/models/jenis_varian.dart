class JenisVarian {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  JenisVarian({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JenisVarian.fromJson(Map<String, dynamic> json) {
    return JenisVarian(
      id: json['id'],
      name: json['nama_judul'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
