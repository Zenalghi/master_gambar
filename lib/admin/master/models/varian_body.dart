import 'package:master_gambar/admin/master/models/jenis_kendaraan.dart';

// Model untuk data Varian Body
class VarianBody {
  final int id;
  final String name;
  final JenisKendaraan jenisKendaraan; // Data induk
  final DateTime createdAt;
  final DateTime updatedAt;

  VarianBody({
    required this.id,
    required this.name,
    required this.jenisKendaraan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VarianBody.fromJson(Map<String, dynamic> json) {
    return VarianBody(
      id: json['id'],
      name: json['varian_body'], // key dari backend
      jenisKendaraan: JenisKendaraan.fromJson(json['jenis_kendaraan']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
