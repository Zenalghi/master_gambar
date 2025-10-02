// File: lib/admin/master/models/gambar_kelistrikan.dart

import 'package:master_gambar/admin/master/models/type_chassis.dart';

// Model untuk data Gambar Kelistrikan
class GambarKelistrikan {
  final int id;
  final String deskripsi;
  final String path;
  final TypeChassis typeChassis; // Data induk
  final DateTime createdAt;
  final DateTime updatedAt;

  GambarKelistrikan({
    required this.id,
    required this.deskripsi,
    required this.path,
    required this.typeChassis,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GambarKelistrikan.fromJson(Map<String, dynamic> json) {
    return GambarKelistrikan(
      id: json['id'],
      deskripsi: json['deskripsi'] ?? 'Tanpa Deskripsi',
      path: json['path_gambar_kelistrikan'],
      typeChassis: TypeChassis.fromJson(json['type_chassis']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
