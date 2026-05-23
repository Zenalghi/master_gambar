// File: lib/admin/master/models/master_varian.dart

import 'package:master_gambar/admin/master/models/jenis_kendaraan.dart';

class MasterVarian {
  final int id;
  final int dJenisKendaraanId;
  final String namaVarian;
  final JenisKendaraan? jenisKendaraan;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MasterVarian({
    required this.id,
    required this.dJenisKendaraanId,
    required this.namaVarian,
    this.jenisKendaraan,
    this.createdAt,
    this.updatedAt,
  });

  factory MasterVarian.fromJson(Map<String, dynamic> json) {
    return MasterVarian(
      id: json['id'] ?? 0,
      dJenisKendaraanId: json['d_jenis_kendaraan_id'] ?? 0,
      namaVarian: json['nama_varian'] ?? '',
      jenisKendaraan: json['jenis_kendaraan'] != null
          ? JenisKendaraan.fromJson(json['jenis_kendaraan'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}
