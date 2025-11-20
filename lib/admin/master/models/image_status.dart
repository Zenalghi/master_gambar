// File: lib/admin/master/models/image_status.dart

import 'package:master_gambar/admin/master/models/varian_body.dart';

class ImageStatus {
  final VarianBody varianBody;
  final DateTime? gambarUtamaUpdatedAt;
  final String? deskripsiOptional;
  final bool hasGambarUtama;

  ImageStatus({
    required this.varianBody,
    this.gambarUtamaUpdatedAt,
    this.deskripsiOptional,
    required this.hasGambarUtama,
  });

  factory ImageStatus.fromJson(Map<String, dynamic> json) {
    return ImageStatus(
      // 1. Parse data Varian Body (dan induknya) menggunakan factory standar
      varianBody: VarianBody.fromJson(json),

      // 2. Ambil data tambahan yang di-select khusus di controller
      gambarUtamaUpdatedAt: json['gambar_utama_updated_at'] != null
          ? DateTime.parse(json['gambar_utama_updated_at'])
          : null,

      deskripsiOptional: json['deskripsi_optional'],

      // 3. Cek keberadaan gambar utama dari relasi yang di-load
      hasGambarUtama: json['gambar_utama'] != null,
    );
  }
}
