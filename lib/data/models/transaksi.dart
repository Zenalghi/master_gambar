// File: lib/data/models/transaksi.dart
class Transaksi {
  final String id;
  // --- TAMBAHKAN INI ---
  final int masterDataId;
  // --------------------
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
    required this.masterDataId, // <-- Tambahkan di constructor
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
      // Pastikan key ini sesuai dengan response JSON dari backend
      // (biasanya snake_case: master_data_id)
      masterDataId: json['master_data_id'] as int,

      customer: Customer.fromJson(json['customer']),
      aTypeEngine: ATypeEngine.fromJson(
        json['a_type_engine'],
      ), // Pastikan key sesuai
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
  final int id;
  final String namaPt;
  final String pj;
  final String? signaturePj;
  Customer({
    required this.id,
    required this.namaPt,
    required this.pj,
    this.signaturePj,
  });
  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json['id'],
    namaPt: json['nama_pt'],
    pj: json['pj'] ?? '',
    signaturePj: json['signature_pj'],
  );
}

class ATypeEngine {
  final String id; // Tambahkan id
  final String typeEngine;
  ATypeEngine({required this.id, required this.typeEngine});
  factory ATypeEngine.fromJson(Map<String, dynamic> json) =>
      ATypeEngine(id: json['id'], typeEngine: json['type_engine']);
}

class BMerk {
  final String id; // Tambahkan id
  final String merk;
  BMerk({required this.id, required this.merk});
  factory BMerk.fromJson(Map<String, dynamic> json) =>
      BMerk(id: json['id'], merk: json['merk']);
}

class CTypeChassis {
  final String id; // Tambahkan id
  final String typeChassis;
  CTypeChassis({required this.id, required this.typeChassis});
  factory CTypeChassis.fromJson(Map<String, dynamic> json) =>
      CTypeChassis(id: json['id'], typeChassis: json['type_chassis']);
}

class DJenisKendaraan {
  final String id; // Tambahkan id
  final String jenisKendaraan;
  DJenisKendaraan({required this.id, required this.jenisKendaraan});
  factory DJenisKendaraan.fromJson(Map<String, dynamic> json) =>
      DJenisKendaraan(id: json['id'], jenisKendaraan: json['jenis_kendaraan']);
}

class FPengajuan {
  final int id;
  final String jenisPengajuan;
  FPengajuan({required this.id, required this.jenisPengajuan});
  factory FPengajuan.fromJson(Map<String, dynamic> json) =>
      FPengajuan(id: json['id'], jenisPengajuan: json['jenis_pengajuan']);
}

class User {
  final int id;
  final String name;
  final String? signature;
  User({required this.id, required this.name, this.signature});
  factory User.fromJson(Map<String, dynamic> json) =>
      User(id: json['id'], name: json['name'], signature: json['signature']);
}
