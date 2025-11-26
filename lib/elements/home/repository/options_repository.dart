// File: lib/elements/home/repository/options_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/core/providers.dart';
import '../../../data/models/option_item.dart';
import '../../../data/models/paginated_response.dart';
import '../../../data/models/transaksi.dart';
import '../../../data/providers/api_endpoints.dart';

// Provider untuk repository ini
final optionsRepositoryProvider = Provider((ref) => OptionsRepository(ref));

class OptionsRepository {
  final Ref _ref;
  OptionsRepository(this._ref);

  // Helper function untuk mengambil dan mem-parsing data
  Future<List<OptionItem>> _fetchOptions(String endpoint) async {
    final response = await _ref.read(apiClientProvider).dio.get(endpoint);
    final List<dynamic> data = response.data;
    return data.map((item) => OptionItem.fromJson(item)).toList();
  }

  // Ubah agar menerima parameter search
  Future<List<OptionItem>> getCustomers(String search) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get(
          ApiEndpoints.customers,
          queryParameters: {'search': search}, // Kirim search ke backend
        );
    final List<dynamic> data = response.data;

    // Mapping manual karena nama kolomnya 'nama_pt', bukan 'name'
    return data
        .map(
          (item) =>
              OptionItem(id: item['id'], name: item['nama_pt'] ?? 'Unknown'),
        )
        .toList();
  }

  Future<List<OptionItem>> getUsers() => _fetchOptions(ApiEndpoints.users);
  Future<List<OptionItem>> getTypeEngines() =>
      _fetchOptions(ApiEndpoints.typeEngines);
  Future<List<OptionItem>> getMerks(String engineId) =>
      _fetchOptions(ApiEndpoints.merks(engineId));
  Future<List<OptionItem>> getTypeChassis(String merkId) =>
      _fetchOptions(ApiEndpoints.typeChassis(merkId));
  Future<List<OptionItem>> getJenisKendaraan(String chassisId) =>
      _fetchOptions(ApiEndpoints.jenisKendaraan(chassisId));
  Future<List<OptionItem>> getJenisPengajuan() =>
      _fetchOptions(ApiEndpoints.jenisPengajuan);

  // --- TAMBAHKAN METHOD INI UNTUK CARI MASTER DATA ---
  Future<List<OptionItem>> getMasterDataOptions(String search) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/options/master-data', queryParameters: {'search': search});
    final List<dynamic> data = response.data;
    // Backend mengirim list dengan key 'name' yang sudah diformat (A / B / C / D)
    return data
        .map((item) => OptionItem.fromJson(item, nameKey: 'name'))
        .toList();
  }

  // --- UPDATE METHOD INI ---
  Future<void> addTransaksi({
    required int customerId,
    required int masterDataId, // <-- Ganti 4 parameter string jadi 1 int
    required int jenisPengajuanId,
  }) async {
    await _ref
        .read(apiClientProvider)
        .dio
        .post(
          ApiEndpoints.transaksi,
          data: {
            "customer_id": customerId,
            "master_data_id": masterDataId, // <-- Kirim ID Master Data
            "f_pengajuan_id": jenisPengajuanId,
          },
        );
  }
}

final transaksiRepositoryProvider = Provider((ref) => TransaksiRepository(ref));

class TransaksiRepository {
  final Ref _ref;
  TransaksiRepository(this._ref);

  Future<PaginatedResponse<Transaksi>> getTransaksiHistory({
    int page = 1,
    int perPage = 25,
    String sortBy = 'updated_at',
    String sortDirection = 'desc',
    String search = '',
    // Tambahkan parameter filter lanjutan
    Map<String, String?>? advancedFilters,
  }) async {
    // 1. Gabungkan parameter dasar
    final Map<String, dynamic> queryParams = {
      'page': page,
      'perPage': perPage,
      'sortBy': sortBy,
      'sortDirection': sortDirection,
      'search': search,
    };

    // 2. Masukkan filter lanjutan jika ada (hapus yang null/kosong)
    if (advancedFilters != null) {
      advancedFilters.forEach((key, value) {
        if (value != null && value.isNotEmpty) {
          queryParams[key] = value;
        }
      });
    }

    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get(ApiEndpoints.transaksi, queryParameters: queryParams);

    return PaginatedResponse.fromJson(response.data, Transaksi.fromJson);
  }

  Future<void> addTransaksi({
    required int customerId,
    required int masterDataId, // <-- Ganti 4 parameter string jadi 1 int
    required int jenisPengajuanId,
  }) async {
    await _ref
        .read(apiClientProvider)
        .dio
        .post(
          ApiEndpoints.transaksi,
          data: {
            "customer_id": customerId,
            "master_data_id": masterDataId, // <-- Kirim ID Master Data
            "f_pengajuan_id": jenisPengajuanId,
          },
        );
  }

  Future<void> updateTransaksi({
    required String transaksiId,
    required int customerId,
    required int masterDataId, // <-- GANTI 4 parameter string menjadi 1 int ini
    required int jenisPengajuanId,
  }) async {
    await _ref
        .read(apiClientProvider)
        .dio
        .put(
          '${ApiEndpoints.transaksi}/$transaksiId',
          data: {
            'customer_id': customerId,
            'master_data_id': masterDataId, // Kirim ID Master Data
            'f_pengajuan_id': jenisPengajuanId,
          },
        );
  }

  Future<void> deleteTransaksi({required String transaksiId}) async {
    await _ref
        .read(apiClientProvider)
        .dio
        .delete(
          '${ApiEndpoints.transaksi}/$transaksiId', // Endpoint -> DELETE /transaksi/{id}
        );
  }
}
