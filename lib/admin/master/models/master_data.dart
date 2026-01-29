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

  // UBAH MENJADI NULLABLE
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Field Tambahan
  final int? kelistrikanId;
  final String? kelistrikanDeskripsi;
  final int? fileKelistrikanId;
  final int? kelistrikanCount;

  MasterData({
    required this.id,
    required this.typeEngine,
    required this.merk,
    required this.typeChassis,
    required this.jenisKendaraan,
    this.createdAt, // Nullable
    this.updatedAt, // Nullable
    this.kelistrikanId,
    this.kelistrikanDeskripsi,
    this.fileKelistrikanId,
    this.kelistrikanCount,
  });

  factory MasterData.fromJson(Map<String, dynamic> json) {
    // Helper lokal untuk handle object kosong/null
    // Jika data komponen null atau id-nya 0 (dummy), kembalikan default value
    Map<String, dynamic> safeMap(dynamic val) {
      if (val == null || val is! Map<String, dynamic>) {
        return {
          'id': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
      }
      return val;
    }

    return MasterData(
      id: json['id'] ?? 0,

      // Gunakan safeMap untuk mencegah error "type 'Null' is not a subtype of type 'int'"
      // pada model anak (TypeEngine, Merk, dll) yang field ID-nya required.
      typeEngine: TypeEngine.fromJson(safeMap(json['type_engine'])),
      merk: Merk.fromJson(safeMap(json['merk'])),
      typeChassis: TypeChassis.fromJson(safeMap(json['type_chassis'])),
      jenisKendaraan: JenisKendaraan.fromJson(safeMap(json['jenis_kendaraan'])),

      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,

      // Field opsional
      kelistrikanId: json['kelistrikan_id'],
      kelistrikanDeskripsi: json['kelistrikan_deskripsi'],
      fileKelistrikanId: json['file_kelistrikan_id'],
      kelistrikanCount: json['kelistrikan_count'],
    );
  }
}
