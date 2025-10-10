// File: lib/admin/master/models/image_status.dart

import 'package:master_gambar/admin/master/models/varian_body.dart';

class ImageStatus {
  final VarianBody varianBody;
  final bool hasGambarUtama;
  final bool hasGambarOptional;

  ImageStatus({
    required this.varianBody,
    required this.hasGambarUtama,
    required this.hasGambarOptional,
  });

  factory ImageStatus.fromJson(Map<String, dynamic> json) {
    return ImageStatus(
      varianBody: VarianBody.fromJson(json), // VarianBody adalah objek root
      hasGambarUtama: json['gambar_utama_exists'] as bool,
      hasGambarOptional: json['gambar_optional_exists'] as bool,
    );
  }
}
