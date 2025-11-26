// lib/data/models/option_item.dart

class OptionItem {
  final dynamic id;
  final String name;
  final Map<String, dynamic>? data; // simpan JSON asli

  OptionItem({required this.id, required this.name, this.data});

  factory OptionItem.fromJson(
    Map<String, dynamic> json, {
    String nameKey = '',
  }) {
    // Tentukan key untuk "name"
    String key = nameKey;

    if (key.isEmpty) {
      if (json.containsKey('nama_pt')) {
        key = 'nama_pt';
      } else if (json.containsKey('type_engine')) {
        key = 'type_engine';
      } else if (json.containsKey('merk')) {
        key = 'merk';
      } else if (json.containsKey('type_chassis')) {
        key = 'type_chassis';
      } else if (json.containsKey('jenis_kendaraan')) {
        key = 'jenis_kendaraan';
      } else if (json.containsKey('jenis_pengajuan')) {
        key = 'jenis_pengajuan';
      } else if (json.containsKey('deskripsi')) {
        key = 'deskripsi';
      } else if (json.containsKey('varian_body')) {
        key = 'varian_body';
      }
      // fallback: kolom "name"
      else if (json.containsKey('name')) {
        key = 'name';
      }
    }

    return OptionItem(
      id: json['id'],
      name: (json[key] ?? 'Unknown').toString(), // aman untuk integer / null
      data: json, // simpan seluruh JSON
    );
  }

  /// Helper: apakah item memiliki gambar?
  bool get hasGambar => data?['has_gambar'] == true || data?['has_gambar'] == 1;
}
