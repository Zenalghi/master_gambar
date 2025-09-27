class Customer {
  final int id;
  final String namaPt;
  final String pj;
  final String? signaturePj;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.namaPt,
    required this.pj,
    this.signaturePj,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      namaPt: json['nama_pt'],
      pj: json['pj'],
      signaturePj: json['signature_pj'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
