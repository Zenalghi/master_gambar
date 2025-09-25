// File: lib/elements/home/repository/options_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/transaksi.dart';
import '../../../app/core/providers.dart';
import '../../../data/models/option_item.dart';
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

  Future<List<OptionItem>> getCustomers() =>
      _fetchOptions(ApiEndpoints.customers);
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
}

class TransaksiRepository {
  final Ref _ref;
  TransaksiRepository(this._ref);
  // Method baru untuk GET histori transaksi
  Future<void> updateTransaksi({
    required String transaksiId,
    required int customerId,
    required String jenisKendaraanId,
    required int jenisPengajuanId,
  }) async {
    // Ekstrak ID induk dari jenis_kendaraan_id
    final String typeEngineId = jenisKendaraanId.substring(0, 2);
    final String merkId = jenisKendaraanId.substring(0, 4);
    final String typeChassisId = jenisKendaraanId.substring(0, 7);

    // Kirim request PUT ke endpoint update
    await _ref
        .read(apiClientProvider)
        .dio
        .put(
          '${ApiEndpoints.transaksi}/$transaksiId', // Endpoint -> /transaksi/{id}
          data: {
            "customer_id": customerId,
            "a_type_engine_id": typeEngineId,
            "b_merk_id": merkId,
            "c_type_chassis_id": typeChassisId,
            "d_jenis_kendaraan_id": jenisKendaraanId,
            "f_pengajuan_id": jenisPengajuanId,
          },
        );
  }

  Future<List<Transaksi>> getTransaksiHistory() async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get(ApiEndpoints.transaksi);
    final List<dynamic> data = response.data;
    return data.map((item) => Transaksi.fromJson(item)).toList();
  }

  Future<void> addTransaksi({
    required int customerId,
    required String typeEngineId,
    required String merkId,
    required String typeChassisId,
    required String jenisKendaraanId,
    required int jenisPengajuanId,
  }) async {
    await _ref
        .read(apiClientProvider)
        .dio
        .post(
          ApiEndpoints.transaksi,
          data: {
            "customer_id": customerId,
            "a_type_engine_id": typeEngineId,
            "b_merk_id": merkId,
            "c_type_chassis_id": typeChassisId,
            "d_jenis_kendaraan_id": jenisKendaraanId,
            "f_pengajuan_id": jenisPengajuanId,
          },
        );
  }
}

// Daftarkan juga providernya
final transaksiRepositoryProvider = Provider((ref) => TransaksiRepository(ref));
