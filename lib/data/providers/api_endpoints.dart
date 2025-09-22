// File: lib/data/providers/api_endpoints.dart
class ApiEndpoints {
  // Base URL sudah ada di ApiClient, jadi kita hanya butuh path-nya
  static const String customers = '/options/customers';
  static const String typeEngines = '/options/type-engines';
  // Untuk endpoint dengan parameter, kita buat fungsi
  static String merks(String engineId) => '/options/merks/$engineId';
  static String typeChassis(String merkId) => '/options/type-chassis/$merkId';
  static String jenisKendaraan(String chassisId) => '/options/jenis-kendaraan/$chassisId';
  static const String jenisPengajuan = '/options/pengajuan';
  
  // Endpoint untuk POST transaksi
  static const String transaksi = '/transaksi';
}