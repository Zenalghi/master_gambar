import 'package:master_gambar/admin/master/models/type_engine.dart';

// Model untuk data Merk, termasuk relasi ke TypeEngine
class Merk {
  final String id;
  final String name;
  final TypeEngine typeEngine; // Data induk
  final DateTime createdAt;
  final DateTime updatedAt;

  Merk({
    required this.id,
    required this.name,
    required this.typeEngine,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Merk.fromJson(Map<String, dynamic> json) {
    return Merk(
      id: json['id'],
      name: json['merk'], // key dari backend
      typeEngine: TypeEngine.fromJson(json['type_engine']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}