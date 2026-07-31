//lib\data\models\customer.dart

class Customer {
  final int id;
  final String namaPt;
  final String pj;
  final String? jabatan;
  final String? signaturePj;
  final String? namaDrafter;
  final String? signatureDrafter;
  final String? namaPemeriksa;
  final String? signaturePemeriksa;
  final String? statusTdp;
  final DateTime? tdpMasaBerlaku;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.namaPt,
    required this.pj,
    this.jabatan,
    this.signaturePj,
    this.namaDrafter,
    this.signatureDrafter,
    this.namaPemeriksa,
    this.signaturePemeriksa,
    this.statusTdp,
    this.tdpMasaBerlaku,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    return Customer(
      id: parseInt(json['id']),
      namaPt: json['nama_pt']?.toString() ?? '-',
      pj: json['pj']?.toString() ?? '-',
      jabatan: json['jabatan']?.toString(),
      signaturePj: json['signature_pj']?.toString(),
      namaDrafter: json['nama_drafter']?.toString(),
      signatureDrafter: json['signature_drafter']?.toString(),
      namaPemeriksa: json['nama_pemeriksa']?.toString(),
      signaturePemeriksa: json['signature_pemeriksa']?.toString(),
      statusTdp: json['status_tdp']?.toString(),
      tdpMasaBerlaku: json['tdp_masa_berlaku'] != null
          ? DateTime.tryParse(json['tdp_masa_berlaku'].toString())?.toLocal()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }
}

