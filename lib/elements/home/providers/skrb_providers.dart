import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:master_gambar/data/models/skrb.dart';
import '../repository/skrb_repository.dart';

final skrbListProvider = FutureProvider<List<Skrb>>((ref) async {
  final repository = ref.watch(skrbRepositoryProvider);
  return repository.getSkrbList();
});

final skrbFilterProvider = StateProvider<Map<String, String>>((ref) => {});

final filteredSkrbListProvider = Provider<AsyncValue<List<Skrb>>>((ref) {
  final listAsync = ref.watch(skrbListProvider);
  final filters = ref.watch(skrbFilterProvider);

  return listAsync.whenData((list) {
    if (filters.isEmpty) return list;
    return list.where((skrb) {
      if (filters['id_skrb']?.isNotEmpty == true &&
          !skrb.idSkrb.toLowerCase().contains(filters['id_skrb']!.toLowerCase())) {
        return false;
      }
      if (filters['id_dwg']?.isNotEmpty == true &&
          !skrb.transaksiId.toLowerCase().contains(filters['id_dwg']!.toLowerCase())) {
        return false;
      }
      if (filters['customer_name']?.isNotEmpty == true &&
          !skrb.customerName.toLowerCase().contains(filters['customer_name']!.toLowerCase())) {
        return false;
      }
      if (filters['type_engine']?.isNotEmpty == true &&
          !skrb.typeEngine.toLowerCase().contains(filters['type_engine']!.toLowerCase())) {
        return false;
      }
      if (filters['merk']?.isNotEmpty == true &&
          !skrb.merk.toLowerCase().contains(filters['merk']!.toLowerCase())) {
        return false;
      }
      if (filters['type_chassis']?.isNotEmpty == true &&
          !skrb.typeChassis.toLowerCase().contains(filters['type_chassis']!.toLowerCase())) {
        return false;
      }
      if (filters['jenis_kendaraan']?.isNotEmpty == true &&
          !skrb.jenisKendaraan.toLowerCase().contains(filters['jenis_kendaraan']!.toLowerCase())) {
        return false;
      }
      if (filters['jenis_pengajuan']?.isNotEmpty == true &&
          !skrb.jenisPengajuan.toLowerCase().contains(filters['jenis_pengajuan']!.toLowerCase())) {
        return false;
      }
      if (filters['status_tdp']?.isNotEmpty == true) {
        if (!skrb.statusTdp.toLowerCase().contains(filters['status_tdp']!.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();
  });
});

final availableTransactionsProvider =
    FutureProvider<List<SkrbAvailableTransaction>>((ref) async {
      final repository = ref.watch(skrbRepositoryProvider);
      return repository.getAvailableTransactions();
    });

final skrbDetailProvider = FutureProvider.family<Skrb, int>((
  ref,
  skrbId,
) async {
  final repository = ref.watch(skrbRepositoryProvider);
  return repository.getSkrbDetail(skrbId);
});

final skrbUnsavedChangesProvider = StateProvider<bool>((ref) => false);
final skrbSaveCallbackProvider = StateProvider<Future<void> Function()?>(
  (ref) => null,
);

final skrbStorageInfoProvider = FutureProvider.family<Map<String, dynamic>, int>((
  ref,
  skrbId,
) async {
  final repository = ref.watch(skrbRepositoryProvider);
  return repository.getSkrbStorageInfo(skrbId);
});
