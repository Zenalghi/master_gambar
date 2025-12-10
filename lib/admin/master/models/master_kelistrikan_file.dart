class MasterKelistrikanFile {
  final int id;
  final String pathFile;
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
      chassisName: json['type_chassis'] ?? 'Unknown',
      merkName: json['merk'] ?? '-',
      engineName: json['type_engine'] ?? '-',

      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
