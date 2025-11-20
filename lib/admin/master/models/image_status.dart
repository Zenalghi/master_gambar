// File: lib/admin/master/models/image_status.dart

import 'g_gambar_utama.dart';
import 'varian_body.dart';

class ImageStatus {
  final VarianBody varianBody;
  // Properti ini wajib ada agar getter 'gambarUtama' dikenali
  final GGambarUtama? gambarUtama;

  // Tambahan properti untuk data laporan
  final DateTime? gambarUtamaUpdatedAt;
  final String? deskripsiOptional;
  final bool hasGambarUtama;

  ImageStatus({
    required this.varianBody,
    this.gambarUtama, // <-- Pastikan ini ada di constructor
    this.gambarUtamaUpdatedAt,
    this.deskripsiOptional,
    required this.hasGambarUtama,
  });

  factory ImageStatus.fromJson(Map<String, dynamic> json) {
    return ImageStatus(
      varianBody: VarianBody.fromJson(json),

      // Parse objek GGambarUtama jika ada
      gambarUtama:
          json['gambarUtama'] !=
              null // Perhatikan key JSON dari backend (biasanya camelCase via Resource atau eager load)
          ? GGambarUtama.fromJson(json['gambarUtama'])
          : (json['gambar_utama'] != null
                ? GGambarUtama.fromJson(json['gambar_utama'])
                : null), // Handle potential naming difference

      gambarUtamaUpdatedAt: json['gambar_utama_updated_at'] != null
          ? DateTime.parse(json['gambar_utama_updated_at'])
          : null,

      deskripsiOptional: json['deskripsi_optional'],

      // Cek keberadaan
      hasGambarUtama:
          json['gambarUtama'] != null || json['gambar_utama'] != null,
    );
  }
}
