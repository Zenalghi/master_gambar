// File: lib/elements/home/providers/transaksi_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../app/core/notifiers/refresh_notifier.dart';
import '../../../data/models/option_item.dart';
import '../repository/options_repository.dart';

// === BAGIAN 1: STATE UNTUK KONTROL UI & FILTER SERVER ===

// State untuk menyimpan jumlah baris per halaman di tabel
final rowsPerPageProvider = StateProvider<int>((ref) => 25);

// State untuk menyimpan query pencarian global

// Provider ini menyimpan semua state untuk paginasi, filter, dan sort
final transaksiFilterProvider = StateProvider<Map<String, String?>>((ref) {
  return {
    'search': '',
    'sortBy': 'updated_at',
    'sortDirection': 'desc',
    'customer': null,
    'type_engine': null,
    'merk': null,
    'type_chassis': null,
    'jenis_kendaraan': null,
    'jenis_pengajuan': null,
    'user': null,
  };
});

// === BAGIAN 2: STATE UNTUK FORM TAMBAH/EDIT (Tidak berubah) ===

final selectedCustomerProvider = StateProvider<int?>((ref) => null);
final selectedTypeEngineProvider = StateProvider<String?>((ref) => null);
final selectedMerkProvider = StateProvider<String?>((ref) => null);
final selectedTypeChassisProvider = StateProvider<String?>((ref) => null);
final selectedJenisKendaraanProvider = StateProvider<String?>((ref) => null);
final selectedJenisPengajuanProvider = StateProvider<int?>((ref) => null);

// === BAGIAN 3: PROVIDER UNTUK MENGAMBIL DATA DROPDOWN ===

// Dropdown mandiri (tidak bergantung pada pilihan lain)
// Provider Customer yang bisa dicari (Searchable)
final customerOptionsSearchProvider =
    FutureProvider.family<List<OptionItem>, String>((ref, search) async {
      // Panggil repository dengan query pencarian
      return ref.read(optionsRepositoryProvider).getCustomers(search);
    });
final userOptionsProvider = FutureProvider<List<OptionItem>>((ref) {
  ref.watch(refreshNotifierProvider);
  return ref.watch(optionsRepositoryProvider).getUsers();
});
final typeEngineOptionsProvider = FutureProvider<List<OptionItem>>((ref) {
  ref.watch(refreshNotifierProvider);
  return ref.watch(optionsRepositoryProvider).getTypeEngines();
});

final jenisPengajuanOptionsProvider = FutureProvider<List<OptionItem>>((ref) {
  ref.watch(refreshNotifierProvider);
  return ref.watch(optionsRepositoryProvider).getJenisPengajuan();
});

// Dropdown bertingkat (bergantung pada pilihan lain), sekarang menggunakan .family

final merkOptionsFamilyProvider =
    FutureProvider.family<List<OptionItem>, String?>((ref, engineId) {
      ref.watch(refreshNotifierProvider);
      if (engineId == null || engineId.isEmpty) return Future.value([]);
      return ref.watch(optionsRepositoryProvider).getMerks(engineId);
    });

final typeChassisOptionsFamilyProvider =
    FutureProvider.family<List<OptionItem>, String?>((ref, merkId) {
      ref.watch(refreshNotifierProvider); // <-- Tambahkan ini
      if (merkId == null || merkId.isEmpty) return Future.value([]);
      return ref.watch(optionsRepositoryProvider).getTypeChassis(merkId);
    });

final jenisKendaraanOptionsFamilyProvider =
    FutureProvider.family<List<OptionItem>, String?>((ref, chassisId) {
      ref.watch(refreshNotifierProvider); // <-- Tambahkan ini
      if (chassisId == null || chassisId.isEmpty) return Future.value([]);
      return ref.watch(optionsRepositoryProvider).getJenisKendaraan(chassisId);
    });

// Provider untuk dropdown Master Data di Transaksi (Searchable)
final transaksiMasterDataOptionsProvider =
    FutureProvider.family<List<OptionItem>, String>((ref, search) async {
      // Menggunakan repository options
      return ref.read(optionsRepositoryProvider).getMasterDataOptions(search);
    });