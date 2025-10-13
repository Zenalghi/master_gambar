class GGambarUtama {
  final int id;
  final DateTime updatedAt;

  GGambarUtama({required this.id, required this.updatedAt});
  factory GGambarUtama.fromJson(Map<String, dynamic> json) {
    return GGambarUtama(
      id: json['id'],
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
