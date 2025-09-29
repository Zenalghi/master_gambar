import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:master_gambar/admin/master/models/merk.dart';
import 'package:master_gambar/admin/master/models/type_engine.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';

import '../../../app/core/providers.dart';
import '../../../data/models/option_item.dart';
import '../../../data/providers/api_endpoints.dart';
import '../models/type_chassis.dart';

final typeEngineSearchQueryProvider = StateProvider<String>((ref) => '');

final typeEngineListProvider = FutureProvider<List<TypeEngine>>((ref) {
  // Watch agar otomatis refresh saat data berubah
  ref.watch(masterDataRepositoryProvider);
  return ref.read(masterDataRepositoryProvider).getTypeEngines();
});

final merkSearchQueryProvider = StateProvider<String>((ref) => '');

final merkListProvider = FutureProvider<List<Merk>>((ref) {
  ref.watch(masterDataRepositoryProvider); // Agar ikut refresh
  return ref.read(masterDataRepositoryProvider).getMerks();
});
final merkRowsPerPageProvider = StateProvider<int>((ref) => 25);
// --- TAMBAHKAN PROVIDER BARU INI ---
// Provider .family untuk dropdown Merk yang bergantung pada Type Engine
final merkOptionsFamilyProvider =
    FutureProvider.family<List<OptionItem>, String?>((ref, typeEngineId) async {
      // Jika tidak ada type engine yang dipilih, kembalikan list kosong
      if (typeEngineId == null || typeEngineId.isEmpty) {
        return [];
      }
      // Panggil endpoint options, bukan repository CRUD
      final response = await ref
          .watch(apiClientProvider)
          .dio
          .get(ApiEndpoints.merks(typeEngineId));
      final List<dynamic> data = response.data;
      return data
          .map((item) => OptionItem.fromJson(item, nameKey: 'merk'))
          .toList();
    });
// ------------------------------------
final typeChassisSearchQueryProvider = StateProvider<String>((ref) => '');

// Provider untuk mengambil daftar Type Chassis
final typeChassisListProvider = FutureProvider<List<TypeChassis>>((ref) {
  ref.watch(masterDataRepositoryProvider);
  return ref.read(masterDataRepositoryProvider).getTypeChassis();
});

// Provider untuk state tabel Type Chassis
final typeChassisRowsPerPageProvider = StateProvider<int>((ref) => 25);
