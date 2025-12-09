// File: lib/admin/master/models/merk.dart

import 'type_engine.dart'; // Pastikan import ini ada

class Merk {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Properti Tambahan (Nested Relation)
  final TypeEngine? typeEngine;

  Merk({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.typeEngine,
  });

  factory Merk.fromJson(Map<String, dynamic> json) {
    return Merk(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['merk'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),

      // Cek apakah ada key 'type_engine' di dalam JSON merk
      typeEngine: json['type_engine'] != null
          ? TypeEngine.fromJson(json['type_engine'])
          : null,
    );
  }
}
