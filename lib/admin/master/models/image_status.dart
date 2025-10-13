// File: lib/admin/master/models/image_status.dart

import 'package:master_gambar/admin/master/models/varian_body.dart';
import 'package:master_gambar/admin/master/models/g_gambar_utama.dart';
import 'package:master_gambar/admin/master/models/gambar_optional.dart';

class ImageStatus {
  final VarianBody varianBody;
  final GGambarUtama? gambarUtama; // <-- Bisa null
  final GambarOptional? latestGambarOptional; // <-- Bisa null

  ImageStatus({
    required this.varianBody,
    this.gambarUtama,
    this.latestGambarOptional,
  });

  factory ImageStatus.fromJson(Map<String, dynamic> json) {
    return ImageStatus(
      varianBody: VarianBody.fromJson(json),
      gambarUtama: json['gambar_utama'] != null
          ? GGambarUtama.fromJson(json['gambar_utama'])
          : null,
      latestGambarOptional: json['latest_gambar_optional'] != null
          ? GambarOptional.fromJson(json['latest_gambar_optional'])
          : null,
    );
  }
}
