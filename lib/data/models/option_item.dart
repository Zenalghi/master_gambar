// File: lib/data/models/option_item.dart
// Kita buat model generik karena strukturnya mirip
class OptionItem {
  final dynamic id; // ID bisa berupa int atau string
  final String name;

  OptionItem({required this.id, required this.name});

  factory OptionItem.fromJson(
    Map<String, dynamic> json, {
    String nameKey = '',
  }) {
    // Menyesuaikan dengan nama kolom yang berbeda di tiap response JSON
    String key = nameKey;
    if (key.isEmpty) {
      if (json.containsKey('nama_pt'))
        key = 'nama_pt';
      else if (json.containsKey('type_engine'))
        key = 'type_engine';
      else if (json.containsKey('merk'))
        key = 'merk';
      else if (json.containsKey('type_chassis'))
        key = 'type_chassis';
      else if (json.containsKey('jenis_kendaraan'))
        key = 'jenis_kendaraan';
      else if (json.containsKey('jenis_pengajuan'))
        key = 'jenis_pengajuan';
    }

    return OptionItem(id: json['id'], name: json[key] ?? 'Unknown');
  }
}
