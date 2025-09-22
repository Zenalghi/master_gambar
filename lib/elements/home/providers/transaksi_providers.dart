// File: lib/elements/home/providers/transaksi_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../data/models/option_item.dart'; // Pastikan model di-import
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
final customerOptionsProvider = FutureProvider<List<OptionItem>>((ref) => ref.watch(optionsRepositoryProvider).getCustomers());
final typeEngineOptionsProvider = FutureProvider<List<OptionItem>>((ref) => ref.watch(optionsRepositoryProvider).getTypeEngines());
final jenisPengajuanOptionsProvider = FutureProvider<List<OptionItem>>((ref) => ref.watch(optionsRepositoryProvider).getJenisPengajuan());

// Dropdown Bersyarat (Dependent)
final merkOptionsProvider = FutureProvider<List<OptionItem>>((ref) { // <-- 1. Tambahkan tipe eksplisit di sini
  final engineId = ref.watch(selectedTypeEngineProvider);
  if (engineId == null) return Future.value(<OptionItem>[]); // <-- 2. Beri tipe pada list kosong
  return ref.watch(optionsRepositoryProvider).getMerks(engineId);
});

final typeChassisOptionsProvider = FutureProvider<List<OptionItem>>((ref) { // <-- 1. Tambahkan tipe eksplisit di sini
  final merkId = ref.watch(selectedMerkProvider);
  if (merkId == null) return Future.value(<OptionItem>[]); // <-- 2. Beri tipe pada list kosong
  return ref.watch(optionsRepositoryProvider).getTypeChassis(merkId);
});

final jenisKendaraanOptionsProvider = FutureProvider<List<OptionItem>>((ref) { // <-- 1. Tambahkan tipe eksplisit di sini
  final chassisId = ref.watch(selectedTypeChassisProvider);
  if (chassisId == null) return Future.value(<OptionItem>[]); // <-- 2. Beri tipe pada list kosong
  return ref.watch(optionsRepositoryProvider).getJenisKendaraan(chassisId);
});

// Provider untuk data histori transaksi
final transaksiHistoryProvider = FutureProvider<List<Transaksi>>((ref) {
  // Kita asumsikan TransaksiRepository sudah ada di file options_repository.dart
  // dan providernya sudah dibuat.
  return ref.watch(transaksiRepositoryProvider).getTransaksiHistory();
});