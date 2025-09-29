import 'package:master_gambar/admin/master/models/type_chassis.dart';

// Model untuk data Jenis Kendaraan
class JenisKendaraan {
  final String id;
  final String name;
  final TypeChassis typeChassis; // Data induk
  final DateTime createdAt;
  final DateTime updatedAt;

  JenisKendaraan({
    required this.id,
    required this.name,
    required this.typeChassis,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JenisKendaraan.fromJson(Map<String, dynamic> json) {
    return JenisKendaraan(
      id: json['id'],
      name: json['jenis_kendaraan'], // key dari backend
      typeChassis: TypeChassis.fromJson(json['type_chassis']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
