import 'package:master_gambar/admin/master/models/varian_body.dart';

// Model untuk data Gambar Optional
class GambarOptional {
  final int id;
  final String deskripsi;
  final String path;
  final VarianBody varianBody; // Data induk
  final DateTime createdAt;
  final DateTime updatedAt;

  GambarOptional({
    required this.id,
    required this.deskripsi,
    required this.path,
    required this.varianBody,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GambarOptional.fromJson(Map<String, dynamic> json) {
    return GambarOptional(
      id: json['id'],
      deskripsi: json['deskripsi'] ?? 'Tanpa Deskripsi',
      path: json['path_gambar_optional'],
      varianBody: VarianBody.fromJson(json['varian_body']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
