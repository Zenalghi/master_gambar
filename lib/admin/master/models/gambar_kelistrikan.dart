// File: lib/admin/master/models/gambar_kelistrikan.dart

import 'package:master_gambar/admin/master/models/merk.dart';
import 'package:master_gambar/admin/master/models/type_chassis.dart';
import 'package:master_gambar/admin/master/models/type_engine.dart';

class GambarKelistrikan {
  final int id;
  final String deskripsi;
  final String path;
  // Sekarang memiliki 3 objek induk secara langsung
  final TypeEngine typeEngine;
  final Merk merk;
  final TypeChassis typeChassis;
  final DateTime createdAt;
  final DateTime updatedAt;

  GambarKelistrikan({
    required this.id,
    required this.deskripsi,
    required this.path,
    required this.typeEngine,
    required this.merk,
    required this.typeChassis,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GambarKelistrikan.fromJson(Map<String, dynamic> json) {
    return GambarKelistrikan(
      id: json['id'],
      deskripsi: json['deskripsi'] ?? 'Tanpa Deskripsi',
      path: json['path_gambar_kelistrikan'],
      // Parse masing-masing objek relasi
      typeEngine: TypeEngine.fromJson(json['type_engine']),
      merk: Merk.fromJson(json['merk']),
      typeChassis: TypeChassis.fromJson(json['type_chassis']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
