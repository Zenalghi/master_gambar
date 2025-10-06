// File: lib/admin/master/models/g_gambar_utama.dart

class GGambarUtama {
  final int id;
  // Tambahkan properti lain jika Anda membutuhkannya dari respons JSON

  GGambarUtama({required this.id});

  factory GGambarUtama.fromJson(Map<String, dynamic> json) {
    return GGambarUtama(id: json['id']);
  }
}
