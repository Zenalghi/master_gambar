// File: lib/admin/master/models/gambar_optional.dart

import 'package:master_gambar/admin/master/models/varian_body.dart';

class GambarOptional {
  final int id;
  final String tipe; // <-- Tambahkan tipe
  final String deskripsi;
  final String path;
  final VarianBody? varianBody; // <-- Jadikan nullable (?)
  final DateTime createdAt;
  final DateTime updatedAt;

  GambarOptional({
    required this.id,
    required this.tipe, // <-- Tambahkan
    required this.deskripsi,
    required this.path,
    this.varianBody, // <-- Jadikan nullable
    required this.createdAt,
    required this.updatedAt,
  });

  factory GambarOptional.fromJson(Map<String, dynamic> json) {
    return GambarOptional(
      id: json['id'],
      tipe: json['tipe'] ?? 'independen', // <-- Tambahkan
      deskripsi: json['deskripsi'] ?? 'Tanpa Deskripsi',
      path: json['path_gambar_optional'],
      // Cek jika varian_body tidak null sebelum di-parse
      varianBody: json['varian_body'] != null
          ? VarianBody.fromJson(json['varian_body'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
