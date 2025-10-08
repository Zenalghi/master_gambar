// File: lib/elements/home/providers/transaksi_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../app/core/notifiers/refresh_notifier.dart';
import '../../../app/core/providers.dart';
import '../../../data/models/option_item.dart';
import '../../../data/models/transaksi.dart';
import '../repository/options_repository.dart';

// 1. PROVIDER UNTUK MENYIMPAN NILAI YANG DIPILIH (Tidak berubah)
final selectedCustomerProvider = StateProvider<int?>((ref) => null);
final selectedTypeEngineProvider = StateProvider<String?>((ref) => null);
final selectedMerkProvider = StateProvider<String?>((ref) => null);
final selectedTypeChassisProvider = StateProvider<String?>((ref) => null);
final selectedJenisKendaraanProvider = StateProvider<String?>((ref) => null);
final selectedJenisPengajuanProvider = StateProvider<int?>((ref) => null);

// 2. PROVIDER UNTUK MENGAMBIL DATA DROPDOWN (Dengan Perbaikan Tipe Data)

// Dropdown mandiri
final customerOptionsProvider = FutureProvider<List<OptionItem>>((ref) {
  ref.watch(refreshNotifierProvider);
  return ref.watch(optionsRepositoryProvider).getCustomers();
});
final typeEngineOptionsProvider = FutureProvider<List<OptionItem>>((ref) {
  ref.watch(refreshNotifierProvider);
  return ref.watch(optionsRepositoryProvider).getTypeEngines();
});
final jenisPengajuanOptionsProvider = FutureProvider<List<OptionItem>>((ref) {
  ref.watch(refreshNotifierProvider);
  return ref.watch(optionsRepositoryProvider).getJenisPengajuan();
});

// Dropdown Bersyarat (Dependent)
final merkOptionsProvider = FutureProvider<List<OptionItem>>((ref) {
  // <-- 1. Tambahkan tipe eksplisit di sini
  final engineId = ref.watch(selectedTypeEngineProvider);
  if (engineId == null)
    return Future.value(<OptionItem>[]); // <-- 2. Beri tipe pada list kosong
  return ref.watch(optionsRepositoryProvider).getMerks(engineId);
});

final typeChassisOptionsProvider = FutureProvider<List<OptionItem>>((ref) {
  // <-- 1. Tambahkan tipe eksplisit di sini
  final merkId = ref.watch(selectedMerkProvider);
  if (merkId == null)
    return Future.value(<OptionItem>[]); // <-- 2. Beri tipe pada list kosong
  return ref.watch(optionsRepositoryProvider).getTypeChassis(merkId);
});

final jenisKendaraanOptionsProvider = FutureProvider<List<OptionItem>>((ref) {
  // <-- 1. Tambahkan tipe eksplisit di sini
  final chassisId = ref.watch(selectedTypeChassisProvider);
  if (chassisId == null)
    return Future.value(<OptionItem>[]); // <-- 2. Beri tipe pada list kosong
  return ref.watch(optionsRepositoryProvider).getJenisKendaraan(chassisId);
});

// Provider untuk data histori transaksi
final transaksiHistoryProvider = FutureProvider<List<Transaksi>>((ref) async {
  // 1. Tonton provider token
  final token = ref.watch(authTokenProvider);

  // 2. Jika tidak ada token (user belum login/sudah logout), jangan lakukan apa-apa
  if (token == null) {
    return []; // Kembalikan list kosong
  }

  // 3. Jika ada token, baru ambil data dari API
  final repo = ref.watch(transaksiRepositoryProvider);
  return repo.getTransaksiHistory();
});

final rowsPerPageProvider = StateProvider<int>((ref) => 25);

// StateProvider untuk menyimpan query pencarian global
final globalSearchQueryProvider = StateProvider<String>((ref) => '');

final customerFilterProvider = StateProvider<String>((ref) => '');
final typeEngineFilterProvider = StateProvider<String>((ref) => '');
final merkFilterProvider = StateProvider<String>((ref) => '');
final typeChassisFilterProvider = StateProvider<String>((ref) => '');
final jenisKendaraanFilterProvider = StateProvider<String>((ref) => '');
final jenisPengajuanFilterProvider = StateProvider<String>((ref) => '');
final userFilterProvider = StateProvider<String>((ref) => '');

final merkOptionsFamilyProvider =
    FutureProvider.family<List<OptionItem>, String?>((ref, engineId) {
      if (engineId == null) return Future.value([]);
      return ref.watch(optionsRepositoryProvider).getMerks(engineId);
    });

final typeChassisOptionsFamilyProvider =
    FutureProvider.family<List<OptionItem>, String?>((ref, merkId) {
      if (merkId == null) return Future.value([]);
      return ref.watch(optionsRepositoryProvider).getTypeChassis(merkId);
    });

final jenisKendaraanOptionsFamilyProvider =
    FutureProvider.family<List<OptionItem>, String?>((ref, chassisId) {
      if (chassisId == null) return Future.value([]);
      return ref.watch(optionsRepositoryProvider).getJenisKendaraan(chassisId);
    });
