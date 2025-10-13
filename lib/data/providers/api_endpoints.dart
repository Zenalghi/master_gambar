// File: lib/data/providers/api_endpoints.dart
class ApiEndpoints {
  // Base URL sudah ada di ApiClient, jadi kita hanya butuh path-nya
  static const String customers = '/options/customers';
  static const String users = '/options/users';
  static const String typeEngines = '/options/type-engines';
  // Untuk endpoint dengan parameter, kita buat fungsi
  static String merks(String engineId) => '/options/merks/$engineId';
  static String typeChassis(String merkId) => '/options/type-chassis/$merkId';
  static String jenisKendaraan(String chassisId) =>
      '/options/jenis-kendaraan/$chassisId';
  static const String jenisPengajuan = '/options/pengajuan';
  static const String judulGambar = '/options/judul-gambar';
  static const String roles = '/options/roles';

  // Endpoint untuk POST transaksi
  static const String transaksi = '/transaksi';

  static String varianBody(String jenisKendaraanId) =>
      '/options/varian-body/$jenisKendaraanId';

  static const String gambarOptionalByVarian =
      '/options/gambar-optional-by-varian';
}
