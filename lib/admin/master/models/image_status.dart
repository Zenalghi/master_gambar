// lib/admin/master/models/image_status.dart

import 'package:master_gambar/admin/master/models/g_gambar_utama.dart';
import 'package:master_gambar/admin/master/models/varian_body.dart';

class ImageStatus {
  final VarianBody varianBody;
  // Properti ini wajib ada untuk mengatasi error getter
  final GGambarUtama? gambarUtama;

  // Data tambahan untuk laporan
  final DateTime? gambarUtamaUpdatedAt;
  final String? deskripsiOptional;
  final bool hasGambarUtama;

  ImageStatus({
    required this.varianBody,
    this.gambarUtama, // <-- Pastikan ini ada
    this.gambarUtamaUpdatedAt,
    this.deskripsiOptional,
    required this.hasGambarUtama,
  });

  factory ImageStatus.fromJson(Map<String, dynamic> json) {
    return ImageStatus(
      // 1. Parse data Varian Body (root object)
      varianBody: VarianBody.fromJson(json),

      // 2. Parse objek GGambarUtama jika ada
      // Backend biasanya mengirim key 'gambar_utama' (snake_case)
      gambarUtama: json['gambar_utama'] != null
          ? GGambarUtama.fromJson(json['gambar_utama'])
          : null,

      // 3. Data tambahan
      gambarUtamaUpdatedAt: json['gambar_utama_updated_at'] != null
          ? DateTime.parse(json['gambar_utama_updated_at'])
          : null,

      deskripsiOptional: json['deskripsi_optional'],

      // 4. Status keberadaan
      hasGambarUtama: json['gambar_utama'] != null,
    );
  }
}
