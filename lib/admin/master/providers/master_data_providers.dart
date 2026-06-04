// lib\admin\master\providers\master_data_providers.dart

import 'dart:typed_data';
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
import '../models/master_data.dart';
import '../models/g_gambar_utama.dart';
import '../models/master_kelistrikan_file.dart';
import '../models/master_varian.dart';

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
  return {'search': '', 'sortBy': 'jenis_kendaraan', 'sortDirection': 'asc'};
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
final typeChassisRowsPerPageProvider = StateProvider<int>((ref) => 50);
// Jenis Kendaraan
final jenisKendaraanRowsPerPageProvider = StateProvider<int>((ref) => 50);
// Varian Body
final varianBodyRowsPerPageProvider = StateProvider<int>((ref) => 50);
final imageStatusRowsPerPageProvider = StateProvider<int>((ref) => 50);
final gambarOptionalRowsPerPageProvider = StateProvider<int>((ref) => 50);
final gambarKelistrikanRowsPerPageProvider = StateProvider<int>((ref) => 50);
final masterDataRowsPerPageProvider = StateProvider<int>((ref) => 50);
final jenisVarianRowsPerPageProvider = StateProvider<int>((ref) => 50);

// --- TAMBAHKAN PROVIDER UNTUK JENIS VARIAN ---
final jenisVarianListProvider = FutureProvider<List<JenisVarian>>((ref) {
  ref.watch(masterDataRepositoryProvider);
  return ref.read(masterDataRepositoryProvider).getJenisVarianList();
});

final jenisVarianSearchQueryProvider = StateProvider<String>((ref) => '');

// State untuk menyimpan ID yang dipilih di setiap dropdown
final mguSelectedTypeEngineIdProvider = StateProvider<String?>((ref) => null);
final mguSelectedMerkIdProvider = StateProvider<String?>((ref) => null);
final mguSelectedTypeChassisIdProvider = StateProvider<String?>((ref) => null);
final mguSelectedJenisKendaraanIdProvider = StateProvider<String?>(
  (ref) => null,
);
final mguSelectedVarianBodyIdProvider = StateProvider<int?>((ref) => null);

class PdfFileData {
  final String name;
  final Uint8List bytes;
  final int size;

  PdfFileData({required this.name, required this.bytes, required this.size});
}

// State untuk menyimpan file-file yang dipilih
final mguGambarUtamaFileProvider = StateProvider<PdfFileData?>((ref) => null);
final mguGambarTeruraiFileProvider = StateProvider<PdfFileData?>((ref) => null);
final mguGambarKontruksiFileProvider = StateProvider<PdfFileData?>(
  (ref) => null,
);
final mguDependentFileProvider = StateProvider<PdfFileData?>((ref) => null);

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

// --- PROVIDER UNTUK TABEL STATUS GAMBAR ---
final imageStatusFilterProvider = StateProvider<Map<String, String>>((ref) {
  return {'search': '', 'sortBy': 'id', 'sortDirection': 'desc'};
});

// --- TAMBAHKAN PROVIDER UNTUK GAMBAR OPTIONAL ---
final gambarOptionalFilterProvider = StateProvider<Map<String, String>>((ref) {
  return {'search': '', 'sortBy': 'updated_at', 'sortDirection': 'desc'};
});

// State untuk checkbox "Tambahkan Gambar Optional Dependen"
final mguShowDependentOptionalProvider = StateProvider<bool>((ref) => false);

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
final editingGambarOptionalProvider = StateProvider<GambarOptional?>(
  (ref) => null,
);
// Provider sederhana untuk men-trigger aksi copy agar UI bereaksi (buka form & snackbar)
final copyGambarOptionalTriggerProvider = StateProvider<int>((ref) => 0);

// --- TAMBAHKAN PROVIDER UNTUK GAMBAR KELISTRIKAN ---
final gambarKelistrikanFilterProvider = StateProvider<Map<String, String>>((
  ref,
) {
  return {'search': '', 'sortBy': 'updated_at', 'sortDirection': 'desc'};
});

final editingKelistrikanFileProvider = StateProvider<MasterKelistrikanFile?>(
  (ref) => null,
);
// == PROVIDER UNTUK MASTER DATA SCREEN ==
final masterDataFilterProvider = StateProvider<Map<String, String>>(
  (ref) => {'search': '', 'sortBy': 'id', 'sortDirection': 'desc'},
);

// Provider untuk Dropdown Searchable (Family agar bisa kirim query search)
final mdTypeEngineOptionsProvider =
    FutureProvider.family<List<OptionItem>, String>((ref, search) async {
      return ref
          .read(masterDataRepositoryProvider)
          .getTypeEngineOptions(search);
    });
final mdMerkOptionsProvider = FutureProvider.family<List<OptionItem>, String>((
  ref,
  search,
) async {
  return ref.read(masterDataRepositoryProvider).getMerkOptions(search);
});
final mdTypeChassisOptionsProvider =
    FutureProvider.family<List<OptionItem>, String>((ref, search) async {
      return ref
          .read(masterDataRepositoryProvider)
          .getTypeChassisOptions(search);
    });
final mdJenisKendaraanOptionsProvider =
    FutureProvider.family<List<OptionItem>, String>((ref, search) async {
      return ref
          .read(masterDataRepositoryProvider)
          .getJenisKendaraanOptions(search);
    });

// Provider untuk Dropdown Master Data (Searchable)
// Menggunakan .family agar kita bisa mengirim text pencarian saat user mengetik
final masterDataOptionsProvider = FutureProvider.family<List<OptionItem>, String>((
  ref,
  search,
) async {
  // Tidak perlu refreshNotifier di sini karena dropdown_search punya mekanisme refresh sendiri
  return ref.read(masterDataRepositoryProvider).getMasterDataOptions(search);
});

// Provider untuk menampung data "Copy Paste" ke halaman Gambar Utama
final initialGambarUtamaDataProvider = StateProvider<Map<String, dynamic>?>(
  (ref) => null,
);

final mguEditingGambarProvider = StateProvider<GGambarUtama?>((ref) => null);

// State untuk menyimpan ID Master Data yang dipilih di form Gambar Utama
final mguSelectedMasterDataIdProvider = StateProvider<int?>((ref) => null);

// State untuk menyimpan Nama Varian Body (jika input manual atau dari dropdown)
final mguSelectedVarianBodyNameProvider = StateProvider<String?>((ref) => null);

// 1. Provider untuk Copy data dari Tabel ke Form Add Master Data
final masterDataToCopyProvider = StateProvider<MasterData?>((ref) => null);

// 2. Provider untuk Auto-Fill Form Kelistrikan (saat navigasi dari Master Data)
final initialKelistrikanDataProvider = StateProvider<Map<String, dynamic>?>(
  (ref) => null,
);

// 3. Provider untuk mengontrol Tab Sidebar (Navigasi)
final adminSidebarIndexProvider = StateProvider<int>((ref) => 0);

// Provider untuk menyimpan Filter Master Data ID pada halaman Varian Body
final selectedMasterDataFilterProvider = StateProvider<OptionItem?>(
  (ref) => null,
);

// ==========================================
// == PROVIDERS MASTER VARIAN (BARU) ==
// ==========================================

// Filter Provider
final masterVarianFilterProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {
    'search': '',
    'sortBy': 'updated_at',
    'sortDirection': 'desc',
    'jenisKendaraanId': null, // Untuk filter berdasarkan JK
  };
});

final masterVarianRowsPerPageProvider = StateProvider<int>((ref) => 50);

// Provider Data Tabel
class MasterVarianDataTableState {
  final bool isLoading;
  final List<MasterVarian> masterVarians;
  final int totalRecords;
  final String? error;

  MasterVarianDataTableState({
    this.isLoading = true,
    this.masterVarians = const [],
    this.totalRecords = 0,
    this.error,
  });

  MasterVarianDataTableState copyWith({
    bool? isLoading,
    List<MasterVarian>? masterVarians,
    int? totalRecords,
    String? error,
  }) {
    return MasterVarianDataTableState(
      isLoading: isLoading ?? this.isLoading,
      masterVarians: masterVarians ?? this.masterVarians,
      totalRecords: totalRecords ?? this.totalRecords,
      error: error ?? this.error,
    );
  }
}

class MasterVarianNotifier extends StateNotifier<MasterVarianDataTableState> {
  final Ref _ref;

  MasterVarianNotifier(this._ref) : super(MasterVarianDataTableState());

  Future<void> fetchMasterVarians() async {
    if (state.masterVarians.isEmpty) {
      state = state.copyWith(isLoading: true, error: null);
    }
    try {
      final filters = _ref.read(masterVarianFilterProvider);
      final perPage = _ref.read(masterVarianRowsPerPageProvider);
      // Kita asumsikan page diatur oleh UI (DataTable2) via startIndex
      final response = await _ref
          .read(masterDataRepositoryProvider)
          .getMasterVarianPaginated(
            page:
                1, // Di-handle terpisah di DataSource jika pakai AsyncDataTableSource
            perPage: perPage,
            search: filters['search'],
            sortBy: filters['sortBy'],
            sortDirection: filters['sortDirection'],
            jenisKendaraanId: filters['jenisKendaraanId'],
          );

      state = state.copyWith(
        isLoading: false,
        masterVarians: response.data,
        totalRecords: response.total,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final masterVarianNotifierProvider =
    StateNotifierProvider<MasterVarianNotifier, MasterVarianDataTableState>((
      ref,
    ) {
      return MasterVarianNotifier(ref);
    });

// Dropdown Multi-Select Provider
final masterVarianOptionsFamilyProvider =
    FutureProvider.family<List<OptionItem>, int>((ref, jenisKendaraanId) async {
      return ref
          .read(masterDataRepositoryProvider)
          .getMasterVarianOptions(jenisKendaraanId);
    });
