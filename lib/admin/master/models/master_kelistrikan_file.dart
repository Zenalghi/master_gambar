// File: lib/admin/master/models/master_kelistrikan_file.dart

class MasterKelistrikanFile {
  final int id;
  final String pathFile;
  // Ubah dari Object ke String
  final String chassisName;
  final String merkName;
  final String engineName;

  final DateTime createdAt;
  final DateTime updatedAt;

  MasterKelistrikanFile({
    required this.id,
    required this.pathFile,
    required this.chassisName,
    required this.merkName,
    required this.engineName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MasterKelistrikanFile.fromJson(Map<String, dynamic> json) {
    return MasterKelistrikanFile(
      id: json['id'],
      pathFile: json['path_file'],
      // Ambil dari alias query Laravel
      chassisName: json['chassis_name'] ?? 'Unknown',
      merkName: json['merk_name'] ?? '-',
      engineName: json['engine_name'] ?? '-',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
