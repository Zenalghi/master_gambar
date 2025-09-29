import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:master_gambar/admin/master/models/merk.dart';
import 'package:master_gambar/admin/master/models/type_engine.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';

final typeEngineListProvider = FutureProvider<List<TypeEngine>>((ref) {
  // Watch agar otomatis refresh saat data berubah
  ref.watch(masterDataRepositoryProvider);
  return ref.read(masterDataRepositoryProvider).getTypeEngines();
});

final merkListProvider = FutureProvider<List<Merk>>((ref) {
  ref.watch(masterDataRepositoryProvider); // Agar ikut refresh
  return ref.read(masterDataRepositoryProvider).getMerks();
});
final merkRowsPerPageProvider = StateProvider<int>((ref) => 25);
