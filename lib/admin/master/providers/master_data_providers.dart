import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:master_gambar/admin/master/models/jenis_kendaraan.dart';
import 'package:master_gambar/admin/master/models/merk.dart';
import 'package:master_gambar/admin/master/models/type_chassis.dart';
import 'package:master_gambar/admin/master/models/type_engine.dart';
import 'package:master_gambar/admin/master/models/varian_body.dart'; // Import model baru
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

final jenisKendaraanListProvider = FutureProvider<List<JenisKendaraan>>((ref) {
  ref.watch(masterDataRepositoryProvider);
  return ref.read(masterDataRepositoryProvider).getJenisKendaraanList();
});

// Provider untuk Varian Body
final varianBodyListProvider = FutureProvider<List<VarianBody>>((ref) {
  ref.watch(masterDataRepositoryProvider);
  return ref.read(masterDataRepositoryProvider).getVarianBodyList();
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
final merkSearchQueryProvider = StateProvider<String>((ref) => '');
// Type Chassis
final typeChassisRowsPerPageProvider = StateProvider<int>((ref) => 25);
final typeChassisSearchQueryProvider = StateProvider<String>((ref) => '');
// Jenis Kendaraan
final jenisKendaraanRowsPerPageProvider = StateProvider<int>((ref) => 25);
final jenisKendaraanSearchQueryProvider = StateProvider<String>((ref) => '');
// Varian Body
final varianBodyRowsPerPageProvider = StateProvider<int>((ref) => 25);
final varianBodySearchQueryProvider = StateProvider<String>((ref) => '');
