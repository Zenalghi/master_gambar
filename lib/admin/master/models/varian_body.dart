// File: lib/admin/master/models/varian_body.dart

import 'master_data.dart';

class VarianBody {
  final int id;
  final String name;
  final MasterData masterData; // <-- Relasi baru ke Master Data
  final DateTime createdAt;
  final DateTime updatedAt;

  VarianBody({
    required this.id,
    required this.name,
    required this.masterData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VarianBody.fromJson(Map<String, dynamic> json) {
    return VarianBody(
      id: json['id'],
      name: json['varian_body'],
      // Pastikan JSON dari backend memuat relasi 'master_data' (camelCase di Laravel biasanya jadi snake_case di JSON kecuali diubah)
      // Berdasarkan controller Anda: $query->with('masterData...')
      masterData: MasterData.fromJson(json['master_data']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
