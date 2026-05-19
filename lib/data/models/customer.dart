//lib\data\models\customer.dart

class Customer {
  final int id;
  final String namaPt;
  final String pj;
  final String? signaturePj;
  final String? namaDrafter;
  final String? signatureDrafter;
  final String? namaPemeriksa;
  final String? signaturePemeriksa;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.namaPt,
    required this.pj,
    this.signaturePj,
    this.namaDrafter,
    this.signatureDrafter,
    this.namaPemeriksa,
    this.signaturePemeriksa,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      namaPt: json['nama_pt'],
      pj: json['pj'],
      signaturePj: json['signature_pj'],
      namaDrafter: json['nama_drafter'],
      signatureDrafter: json['signature_drafter'],
      namaPemeriksa: json['nama_pemeriksa'],
      signaturePemeriksa: json['signature_pemeriksa'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
