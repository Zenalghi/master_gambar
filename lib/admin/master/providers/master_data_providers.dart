// ignore_for_file: unused_import

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:master_gambar/admin/master/models/type_engine.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:master_gambar/app/core/providers.dart';
import 'package:master_gambar/data/models/option_item.dart';
import 'package:master_gambar/data/providers/api_endpoints.dart';
import '../../../app/core/notifiers/refresh_notifier.dart';
import '../models/gambar_optional.dart';
import '../models/jenis_varian.dart';

// == PROVIDER UNTUK MENGAMBIL DATA LIST LENGKAP ==
final typeEngineListProvider = FutureProvider<List<TypeEngine>>((ref) {
  ref.watch(refreshNotifierProvider);
  ref.watch(masterDataRepositoryProvider);
  return ref.read(masterDataRepositoryProvider).getTypeEngines();
});

final merkFilterProvider = StateProvider<Map<String, String>>((ref) {
  return {'search': '', 'sortBy': 'id', 'sortDirection': 'asc'};
});

final typeChassisFilterProvider = StateProvider<Map<String, String>>((ref) {
  return {'search': '', 'sortBy': 'id', 'sortDirection': 'asc'};
});

final jenisKendaraanFilterProvider = StateProvider<Map<String, String>>((ref) {
  return {'search': '', 'sortBy': 'id', 'sortDirection': 'asc'};
});

// Provider untuk Varian Body
final varianBodyFilterProvider = StateProvider<Map<String, String>>((ref) {
  return {
    'search': '',
    'sortBy': 'updated_at', // Default sort
    'sortDirection': 'desc', // Default direction
  };
});

// == PROVIDER UNTUK DROPDOWN DINAMIS (OPTIONS) ==
final merkOptionsFamilyProvider =
    FutureProvider.family<List<OptionItem>, String?>((ref, typeEngineId) async {
      if (typeEngineId == null || typeEngineId.isEmpty) return [];
      final response = await ref
          .watch(apiClientProvider)
          .dio
          .get(ApiEndpoints.merks(typeEngineId));
      final List<dynamic> data = response.data;
      return data
          .map((item) => OptionItem.fromJson(item, nameKey: 'merk'))
          .toList();
    });

final typeChassisOptionsFamilyProvider =
    FutureProvider.family<List<OptionItem>, String?>((ref, merkId) async {
      if (merkId == null || merkId.isEmpty) return [];
      final response = await ref
          .watch(apiClientProvider)
          .dio
          .get(ApiEndpoints.typeChassis(merkId));
      final List<dynamic> data = response.data;
      return data
          .map((item) => OptionItem.fromJson(item, nameKey: 'type_chassis'))
          .toList();
    });

final jenisVarianOptionsProvider = FutureProvider<List<OptionItem>>((
  ref,
) async {
  final response = await ref
      .watch(apiClientProvider)
      .dio
      .get(ApiEndpoints.judulGambar);
  final List<dynamic> data = response.data;
  return data
      .map((item) => OptionItem.fromJson(item, nameKey: 'name'))
      .toList();
});
// Provider .family untuk dropdown Jenis Kendaraan yang bergantung pada Type Chassis
final jenisKendaraanOptionsFamilyProvider =
    FutureProvider.family<List<OptionItem>, String?>((
      ref,
      typeChassisId,
    ) async {
      if (typeChassisId == null || typeChassisId.isEmpty) return [];
      final response = await ref
          .watch(apiClientProvider)
          .dio
          .get(ApiEndpoints.jenisKendaraan(typeChassisId));
      final List<dynamic> data = response.data;
      return data
          .map((item) => OptionItem.fromJson(item, nameKey: 'jenis_kendaraan'))
          .toList();
    });

// == PROVIDER UNTUK STATE UI (PAGINASI & SEARCH) ==
// Type Engine
final typeEngineSearchQueryProvider = StateProvider<String>((ref) => '');
// Merk
final merkRowsPerPageProvider = StateProvider<int>((ref) => 25);
// Type Chassis
final typeChassisRowsPerPageProvider = StateProvider<int>((ref) => 25);
// Jenis Kendaraan
final jenisKendaraanRowsPerPageProvider = StateProvider<int>((ref) => 25);
// Varian Body
final varianBodyRowsPerPageProvider = StateProvider<int>((ref) => 25);
final imageStatusRowsPerPageProvider = StateProvider<int>((ref) => 25);

// --- TAMBAHKAN PROVIDER UNTUK JENIS VARIAN ---
final jenisVarianListProvider = FutureProvider<List<JenisVarian>>((ref) {
  ref.watch(masterDataRepositoryProvider);
  return ref.read(masterDataRepositoryProvider).getJenisVarianList();
});

final jenisVarianRowsPerPageProvider = StateProvider<int>((ref) => 13);
final jenisVarianSearchQueryProvider = StateProvider<String>((ref) => '');

// State untuk menyimpan ID yang dipilih di setiap dropdown
final mguSelectedTypeEngineIdProvider = StateProvider<String?>((ref) => null);
final mguSelectedMerkIdProvider = StateProvider<String?>((ref) => null);
final mguSelectedTypeChassisIdProvider = StateProvider<String?>((ref) => null);
final mguSelectedJenisKendaraanIdProvider = StateProvider<String?>(
  (ref) => null,
);
final mguSelectedVarianBodyIdProvider = StateProvider<int?>((ref) => null);

// State untuk menyimpan file-file yang dipilih
final mguGambarUtamaFileProvider = StateProvider<File?>((ref) => null);
final mguGambarTeruraiFileProvider = StateProvider<File?>((ref) => null);
final mguGambarKontruksiFileProvider = StateProvider<File?>((ref) => null);

// Provider untuk dropdown Varian Body (berdasarkan Jenis Kendaraan)
// Kita menggunakan OptionItem karena hanya butuh ID dan nama
final varianBodyOptionsFamilyProvider =
    FutureProvider.family<List<OptionItem>, String?>((
      ref,
      jenisKendaraanId,
    ) async {
      if (jenisKendaraanId == null || jenisKendaraanId.isEmpty) return [];
      final response = await ref
          .watch(apiClientProvider)
          .dio
          .get(ApiEndpoints.varianBody(jenisKendaraanId));
      final List<dynamic> data = response.data;
      return data
          .map((item) => OptionItem.fromJson(item, nameKey: 'varian_body'))
          .toList();
    });

// --- TAMBAHKAN PROVIDER UNTUK GAMBAR OPTIONAL ---
final gambarOptionalFilterProvider = StateProvider<Map<String, String>>((ref) {
  return {'search': '', 'sortBy': 'updated_at', 'sortDirection': 'desc'};
});

final gambarOptionalRowsPerPageProvider = StateProvider<int>((ref) => 25);

// --- TAMBAHKAN PROVIDER UNTUK GAMBAR KELISTRIKAN ---
final gambarKelistrikanFilterProvider = StateProvider<Map<String, String>>((
  ref,
) {
  return {'search': '', 'sortBy': 'updated_at', 'sortDirection': 'desc'};
});

final gambarKelistrikanRowsPerPageProvider = StateProvider<int>((ref) => 25);

// State untuk checkbox "Tambahkan Gambar Optional Dependen"
final mguShowDependentOptionalProvider = StateProvider<bool>((ref) => false);

// State untuk file PDF opsional dependen yang dipilih
final mguDependentFileProvider = StateProvider<File?>((ref) => null);

// --- TAMBAHKAN PROVIDER BARU UNTUK TABEL STATUS GAMBAR ---
final imageStatusFilterProvider = StateProvider<Map<String, String>>((ref) {
  return {'search': '', 'sortBy': 'updated_at', 'sortDirection': 'desc'};
});

// Provider ini akan melakukan pengecekan ke backend saat Varian Body dipilih
final hasExistingPaketOptionalProvider = FutureProvider<bool>((ref) async {
  final selectedVarianBodyId = ref.watch(mguSelectedVarianBodyIdProvider);

  // Jika belum ada Varian Body dipilih, anggap tidak ada
  if (selectedVarianBodyId == null) {
    return false;
  }

  // Panggil repository untuk mengecek
  return ref
      .watch(masterDataRepositoryProvider)
      .checkPaketOptionalExists(selectedVarianBodyId);
});
