import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:master_gambar/admin/master/models/jenis_kendaraan.dart';
import 'package:master_gambar/admin/master/models/merk.dart';
import 'package:master_gambar/admin/master/models/type_chassis.dart';
import 'package:master_gambar/admin/master/models/type_engine.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:master_gambar/app/core/providers.dart';
import 'package:master_gambar/data/models/option_item.dart';
import 'package:master_gambar/data/providers/api_endpoints.dart';

// == PROVIDER UNTUK MENGAMBIL DATA LIST LENGKAP ==
final typeEngineListProvider = FutureProvider<List<TypeEngine>>((ref) {
  ref.watch(masterDataRepositoryProvider);
  return ref.read(masterDataRepositoryProvider).getTypeEngines();
});

final merkListProvider = FutureProvider<List<Merk>>((ref) {
  ref.watch(masterDataRepositoryProvider);
  return ref.read(masterDataRepositoryProvider).getMerks();
});

final typeChassisListProvider = FutureProvider<List<TypeChassis>>((ref) {
  ref.watch(masterDataRepositoryProvider);
  return ref.read(masterDataRepositoryProvider).getTypeChassis();
});

// Provider untuk Jenis Kendaraan
final jenisKendaraanListProvider = FutureProvider<List<JenisKendaraan>>((ref) {
  ref.watch(masterDataRepositoryProvider);
  return ref.read(masterDataRepositoryProvider).getJenisKendaraanList();
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

// Provider .family untuk dropdown Type Chassis yang bergantung pada Merk
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

// == PROVIDER UNTUK STATE UI (PAGINASI & SEARCH) ==
// Type Engine
final typeEngineSearchQueryProvider = StateProvider<String>((ref) => '');
// Merk
final merkRowsPerPageProvider = StateProvider<int>((ref) => 25);
final merkSearchQueryProvider = StateProvider<String>((ref) => '');
// Type Chassis
final typeChassisRowsPerPageProvider = StateProvider<int>((ref) => 25);
final typeChassisSearchQueryProvider = StateProvider<String>((ref) => '');
// Jenis Kendaraan
final jenisKendaraanRowsPerPageProvider = StateProvider<int>((ref) => 25);
final jenisKendaraanSearchQueryProvider = StateProvider<String>((ref) => '');
