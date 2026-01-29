// lib/admin/master/models/g_gambar_utama.dart
import 'package:master_gambar/admin/master/models/gambar_optional.dart';

class GGambarUtama {
  final int id;
  final DateTime? updatedAt;
  final List<GambarOptional> gambarOptionals;

  // Field path Wajib ada
  final String? pathGambarUtama;
  final String? pathGambarTerurai;
  final String? pathGambarKontruksi;

  GGambarUtama({
    required this.id,
    this.updatedAt,
    required this.gambarOptionals,
    this.pathGambarUtama,
    this.pathGambarTerurai,
    this.pathGambarKontruksi,
  });

  factory GGambarUtama.fromJson(Map<String, dynamic> json) {
    return GGambarUtama(
      id: json['id'] ?? 0,

      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,

      // --- Pastikan key ini sesuai dengan yang dikirim controller ---
      // Controller mengirim snake_case: path_gambar_utama
      pathGambarUtama: json['path_gambar_utama'],
      pathGambarTerurai: json['path_gambar_terurai'],
      pathGambarKontruksi: json['path_gambar_kontruksi'],

      gambarOptionals: json['gambar_optionals'] != null
          ? (json['gambar_optionals'] as List)
                .map((item) => GambarOptional.fromJson(item))
                .toList()
          : [],
    );
  }
}
