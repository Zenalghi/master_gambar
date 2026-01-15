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
  final DateTime createdAt;
  final DateTime updatedAt;

  // Field Tambahan untuk Kelistrikan
  final int? kelistrikanId;
  final String? kelistrikanDeskripsi; // Deskripsinya
  final int? fileKelistrikanId;
  final int? kelistrikanCount;
  MasterData({
    required this.id,
    required this.typeEngine,
    required this.merk,
    required this.typeChassis,
    required this.jenisKendaraan,
    required this.createdAt,
    required this.updatedAt,
    this.kelistrikanId,
    this.kelistrikanDeskripsi,
    this.fileKelistrikanId,
    this.kelistrikanCount,
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

      // Mapping data kelistrikan dari Controller
      kelistrikanId: json['kelistrikan_id'],
      kelistrikanDeskripsi: json['kelistrikan_deskripsi'],
      fileKelistrikanId: json['file_kelistrikan_id'],
      kelistrikanCount: json['kelistrikan_count'],
    );
  }
}
