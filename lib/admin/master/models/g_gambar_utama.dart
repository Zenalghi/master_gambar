import 'package:master_gambar/admin/master/models/gambar_optional.dart';

class GGambarUtama {
  final int id;
  final DateTime updatedAt;
  final List<GambarOptional> gambarOptionals;

  GGambarUtama({
    required this.id,
    required this.updatedAt,
    required this.gambarOptionals,
  });

  factory GGambarUtama.fromJson(Map<String, dynamic> json) {
    return GGambarUtama(
      id: json['id'],
      updatedAt: DateTime.parse(json['updated_at']),
      gambarOptionals: json['gambar_optionals'] != null
          ? (json['gambar_optionals'] as List)
                .map((item) => GambarOptional.fromJson(item))
                .toList()
          : [],
    );
  }
}
