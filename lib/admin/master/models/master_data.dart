// File: lib/admin/master/models/master_data.dart
import 'type_engine.dart';
import 'merk.dart';
import 'type_chassis.dart';
import 'jenis_kendaraan.dart';

class MasterData {
  final int id;
  final TypeEngine typeEngine;
  final Merk merk;
  final TypeChassis typeChassis;
  final JenisKendaraan jenisKendaraan;
  final int? kelistrikanId; // ID gambar kelistrikan (jika ada)
  final DateTime createdAt;
  final DateTime updatedAt;

  MasterData({
    required this.id,
    required this.typeEngine,
    required this.merk,
    required this.typeChassis,
    required this.jenisKendaraan,
    this.kelistrikanId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MasterData.fromJson(Map<String, dynamic> json) {
    return MasterData(
      id: json['id'],
      typeEngine: TypeEngine.fromJson(json['type_engine']),
      merk: Merk.fromJson(json['merk']),
      typeChassis: TypeChassis.fromJson(json['type_chassis']),
      jenisKendaraan: JenisKendaraan.fromJson(json['jenis_kendaraan']),
      kelistrikanId: json['kelistrikan_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
