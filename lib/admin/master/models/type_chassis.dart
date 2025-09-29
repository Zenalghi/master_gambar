import 'package:master_gambar/admin/master/models/merk.dart';

// Model untuk data Type Chassis
class TypeChassis {
  final String id;
  final String name;
  final Merk merk; // Data induk
  final DateTime createdAt;
  final DateTime updatedAt;

  TypeChassis({
    required this.id,
    required this.name,
    required this.merk,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TypeChassis.fromJson(Map<String, dynamic> json) {
    return TypeChassis(
      id: json['id'],
      name: json['type_chassis'], // key dari backend
      merk: Merk.fromJson(json['merk']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
