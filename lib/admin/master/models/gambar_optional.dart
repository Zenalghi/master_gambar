// lib/admin/master/models/gambar_optional.dart

import 'package:master_gambar/admin/master/models/varian_body.dart';
import 'package:master_gambar/admin/master/models/master_data.dart'; // Pastikan import MasterData

class GambarOptional {
  final int id;
  final String tipe;
  final String deskripsi;
  final String path;
  final int? masterDataId;

  // Relasi
  final VarianBody? varianBody; // Bisa null (jika independen)
  final MasterData? masterData; // Baru: Untuk independen

  final DateTime createdAt;
  final DateTime updatedAt;

  GambarOptional({
    required this.id,
    required this.tipe,
    required this.deskripsi,
    required this.path,
    this.masterDataId,
    this.varianBody,
    this.masterData, // Baru
    required this.createdAt,
    required this.updatedAt,
  });

  factory GambarOptional.fromJson(Map<String, dynamic> json) {
    return GambarOptional(
      id: json['id'],
      tipe: json['tipe'],
      deskripsi: json['deskripsi'] ?? 'Tanpa Deskripsi',
      path: json['path_gambar_optional'] ?? '',
      masterDataId: json['master_data_id'],

      // Parse Varian Body (jika ada)
      varianBody: json['varian_body'] != null
          ? VarianBody.fromJson(json['varian_body'])
          : null,

      // Parse Master Data (jika ada - KHUSUS INDEPENDEN)
      masterData: json['master_data'] != null
          ? MasterData.fromJson(json['master_data'])
          : null,

      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
