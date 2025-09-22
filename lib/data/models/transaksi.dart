// File: lib/data/models/transaksi.dart
class Transaksi {
  final String id;
  final Customer customer;
  final ATypeEngine aTypeEngine;
  final BMerk bMerk;
  final CTypeChassis cTypeChassis;
  final DJenisKendaraan dJenisKendaraan;
  final FPengajuan fPengajuan;
  final User user;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaksi({
    required this.id,
    required this.customer,
    required this.aTypeEngine,
    required this.bMerk,
    required this.cTypeChassis,
    required this.dJenisKendaraan,
    required this.fPengajuan,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      id: json['id'],
      customer: Customer.fromJson(json['customer']),
      aTypeEngine: ATypeEngine.fromJson(json['a_type_engine']),
      bMerk: BMerk.fromJson(json['b_merk']),
      cTypeChassis: CTypeChassis.fromJson(json['c_type_chassis']),
      dJenisKendaraan: DJenisKendaraan.fromJson(json['d_jenis_kendaraan']),
      fPengajuan: FPengajuan.fromJson(json['f_pengajuan']),
      user: User.fromJson(json['user']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

// Sub-model untuk data yang bersarang
class Customer {
  final String namaPt;
  Customer({required this.namaPt});
  factory Customer.fromJson(Map<String, dynamic> json) => Customer(namaPt: json['nama_pt']);
}
class ATypeEngine {
  final String typeEngine;
  ATypeEngine({required this.typeEngine});
  factory ATypeEngine.fromJson(Map<String, dynamic> json) => ATypeEngine(typeEngine: json['type_engine']);
}
class BMerk {
  final String merk;
  BMerk({required this.merk});
  factory BMerk.fromJson(Map<String, dynamic> json) => BMerk(merk: json['merk']);
}
class CTypeChassis {
  final String typeChassis;
  CTypeChassis({required this.typeChassis});
  factory CTypeChassis.fromJson(Map<String, dynamic> json) => CTypeChassis(typeChassis: json['type_chassis']);
}

class DJenisKendaraan {
  final String jenisKendaraan;
  DJenisKendaraan({required this.jenisKendaraan});
  factory DJenisKendaraan.fromJson(Map<String, dynamic> json) => DJenisKendaraan(jenisKendaraan: json['jenis_kendaraan']);
}

class FPengajuan {
  final String jenisPengajuan;
  FPengajuan({required this.jenisPengajuan});
  factory FPengajuan.fromJson(Map<String, dynamic> json) => FPengajuan(jenisPengajuan: json['jenis_pengajuan']);
}

class User {
  final String name;
  User({required this.name});
  factory User.fromJson(Map<String, dynamic> json) => User(name: json['name']);
}