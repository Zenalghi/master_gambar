// File: lib/admin/master/models/master_kelistrikan_file.dart

import 'package:master_gambar/admin/master/models/type_chassis.dart';

class MasterKelistrikanFile {
  final int id;
  final String pathFile;
  final TypeChassis typeChassis; // Berisi Merk & Engine (nested)
  final DateTime createdAt;
  final DateTime updatedAt;

  MasterKelistrikanFile({
    required this.id,
    required this.pathFile,
    required this.typeChassis,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MasterKelistrikanFile.fromJson(Map<String, dynamic> json) {
    return MasterKelistrikanFile(
      id: json['id'],
      pathFile: json['path_file'],
      // Backend mengirim key 'chassis' (dari relasi)
      typeChassis: TypeChassis.fromJson(json['chassis']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
