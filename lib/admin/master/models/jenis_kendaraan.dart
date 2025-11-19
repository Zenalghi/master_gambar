// File: lib/admin/master/models/jenis_kendaraan.dart

class JenisKendaraan {
  final int id; // <-- BERUBAH: int
  final String name;
  // final TypeChassis typeChassis; <-- DIHAPUS (Independen)
  final DateTime createdAt;
  final DateTime updatedAt;

  JenisKendaraan({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JenisKendaraan.fromJson(Map<String, dynamic> json) {
    return JenisKendaraan(
      id: json['id'] as int, // Parse as int
      name: json['jenis_kendaraan'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
