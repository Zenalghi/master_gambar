import 'package:master_gambar/admin/master/models/g_gambar_utama.dart';
import 'package:master_gambar/admin/master/models/varian_body.dart';

class ImageStatus {
  final VarianBody varianBody;
  final GGambarUtama? gambarUtama;

  ImageStatus({required this.varianBody, this.gambarUtama});

  factory ImageStatus.fromJson(Map<String, dynamic> json) {
    return ImageStatus(
      varianBody: VarianBody.fromJson(json),
      gambarUtama: json['gambar_utama'] != null
          ? GGambarUtama.fromJson(json['gambar_utama'])
          : null,
    );
  }
}
