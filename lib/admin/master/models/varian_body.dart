import 'master_data.dart';

class VarianBody {
  final int id;
  final String name;
  final MasterData masterData;

  // UBAH MENJADI NULLABLE
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VarianBody({
    required this.id,
    required this.name,
    required this.masterData,
    this.createdAt, // Nullable
    this.updatedAt, // Nullable
  });

  factory VarianBody.fromJson(Map<String, dynamic> json) {
    return VarianBody(
      id: json['id'] ?? 0, // Safety check
      name: json['varian_body'] ?? 'Unknown',

      // Parse Master Data
      masterData: MasterData.fromJson(json['master_data'] ?? {}),

      // Handle Nullable Date
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}
