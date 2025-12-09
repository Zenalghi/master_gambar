// lib/admin/master/models/master_data.dart
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? kelistrikanId; // ID gambar kelistrikan (jika ada)
  final String? kelistrikanDeskripsi;
  final int? fileKelistrikanId; // File ID

  MasterData({
    required this.id,
    required this.typeEngine,
    required this.merk,
    required this.typeChassis,
    required this.jenisKendaraan,
    this.kelistrikanId,
    this.kelistrikanDeskripsi,
    this.fileKelistrikanId,
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
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      kelistrikanId: json['kelistrikan_id'],
      kelistrikanDeskripsi: json['kelistrikan_deskripsi'],
      fileKelistrikanId: json['file_kelistrikan_id'],
    );
  }
}
