// lib/admin/master/models/image_status.dart

import 'package:master_gambar/admin/master/models/g_gambar_utama.dart';
import 'package:master_gambar/admin/master/models/varian_body.dart';

class ImageStatus {
  final VarianBody varianBody;
  final GGambarUtama? gambarUtama;

  final DateTime? gambarUtamaCreatedAt;
  final DateTime? gambarUtamaUpdatedAt;
  final String? deskripsiOptional;
  final bool hasGambarUtama;

  ImageStatus({
    required this.varianBody,
    this.gambarUtama,
    this.gambarUtamaCreatedAt,
    this.gambarUtamaUpdatedAt,
    this.deskripsiOptional,
    required this.hasGambarUtama,
  });

  factory ImageStatus.fromJson(Map<String, dynamic> json) {
    return ImageStatus(
      varianBody: VarianBody.fromJson(json),

      // KOREKSI: Backend mengirim object 'gambar_utama' hasil rekonstruksi
      gambarUtama: json['gambar_utama'] != null
          ? GGambarUtama.fromJson(json['gambar_utama'])
          : null,

      gambarUtamaCreatedAt: json['gambar_utama_created_at'] != null
          ? DateTime.tryParse(json['gambar_utama_created_at'].toString())
          : null,

      gambarUtamaUpdatedAt: json['gambar_utama_updated_at'] != null
          ? DateTime.tryParse(json['gambar_utama_updated_at'].toString())
          : null,

      deskripsiOptional: json['deskripsi_optional'],
      hasGambarUtama: json['gambar_utama'] != null, // Cek keberadaan object
    );
  }
}
