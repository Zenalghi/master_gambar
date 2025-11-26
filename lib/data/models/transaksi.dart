// File: lib/data/models/transaksi.dart

class Transaksi {
  final String id;
  final int masterDataId;
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
    required this.masterDataId,
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
      // Gunakan toString() untuk ID transaksi agar aman
      id: json['id'].toString(),

      // master_data_id adalah integer dari database
      masterDataId: json['master_data_id'] is int
          ? json['master_data_id']
          : int.tryParse(json['master_data_id'].toString()) ?? 0,

      // Parse nested objects
      // Pastikan backend mengirim key 'customer', 'a_type_engine', dll.
      customer: Customer.fromJson(json['customer'] ?? {}),
      aTypeEngine: ATypeEngine.fromJson(json['a_type_engine'] ?? {}),
      bMerk: BMerk.fromJson(json['b_merk'] ?? {}),
      cTypeChassis: CTypeChassis.fromJson(json['c_type_chassis'] ?? {}),
      dJenisKendaraan: DJenisKendaraan.fromJson(
        json['d_jenis_kendaraan'] ?? {},
      ),
      fPengajuan: FPengajuan.fromJson(json['f_pengajuan'] ?? {}),
      user: User.fromJson(json['user'] ?? {}),

      // Parse tanggal
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

// === Sub-model ===

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
    // Handle kemungkinan ID dikirim sebagai String
    id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
    namaPt: json['nama_pt'].toString(),
    pj: (json['pj'] ?? '').toString(),
    signaturePj: json['signature_pj'],
  );
}

class ATypeEngine {
  final String id;
  final String typeEngine;

  ATypeEngine({required this.id, required this.typeEngine});

  factory ATypeEngine.fromJson(Map<String, dynamic> json) => ATypeEngine(
    // FIX: Gunakan .toString() agar Integer ID dari DB diterima sebagai String
    id: json['id'].toString(),
    typeEngine: (json['type_engine'] ?? '').toString(),
  );
}

class BMerk {
  final String id;
  final String merk;

  BMerk({required this.id, required this.merk});

  factory BMerk.fromJson(Map<String, dynamic> json) => BMerk(
    // FIX: Gunakan .toString()
    id: json['id'].toString(),
    merk: (json['merk'] ?? '').toString(),
  );
}

class CTypeChassis {
  final String id;
  final String typeChassis;

  CTypeChassis({required this.id, required this.typeChassis});

  factory CTypeChassis.fromJson(Map<String, dynamic> json) => CTypeChassis(
    // FIX: Gunakan .toString()
    id: json['id'].toString(),
    typeChassis: (json['type_chassis'] ?? '').toString(),
  );
}

class DJenisKendaraan {
  final String id;
  final String jenisKendaraan;

  DJenisKendaraan({required this.id, required this.jenisKendaraan});

  factory DJenisKendaraan.fromJson(Map<String, dynamic> json) =>
      DJenisKendaraan(
        // FIX: Gunakan .toString()
        id: json['id'].toString(),
        jenisKendaraan: (json['jenis_kendaraan'] ?? '').toString(),
      );
}

class FPengajuan {
  final int id;
  final String jenisPengajuan;

  FPengajuan({required this.id, required this.jenisPengajuan});

  factory FPengajuan.fromJson(Map<String, dynamic> json) => FPengajuan(
    id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
    jenisPengajuan: (json['jenis_pengajuan'] ?? '').toString(),
  );
}

class User {
  final int id;
  final String name;
  final String? signature;

  User({required this.id, required this.name, this.signature});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
    name: (json['name'] ?? '').toString(),
    signature: json['signature'],
  );
}
