// lib/data/models/option_item.dart

class OptionItem {
  final dynamic id;
  final String name;

  OptionItem({required this.id, required this.name});

  factory OptionItem.fromJson(
    Map<String, dynamic> json, {
    String nameKey = '',
  }) {
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
      }
      // Fallback jika nama kolomnya 'name' (biasanya dari User)
      else if (json.containsKey('name')) {
        key = 'name';
      }
    }

    // FIX UTAMA DISINI:
    // Tambahkan .toString() agar Integer (misal: 1500) aman dikonversi jadi String "1500"
    return OptionItem(
      id: json['id'],
      name: (json[key] ?? 'Unknown').toString(),
    );
  }
}
