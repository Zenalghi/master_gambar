import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:master_gambar/data/models/option_item.dart';
// import 'package:master_gambar/data/models/transaksi.dart';

import '../../../app/core/providers.dart';
import '../../../data/providers/api_endpoints.dart';

// === State untuk Pilihan Utama ===

// Menyimpan pilihan jumlah gambar (1-4)
final jumlahGambarProvider = StateProvider<int>((ref) => 1);

// Menyimpan ID pemeriksa yang dipilih
final pemeriksaIdProvider = StateProvider<int?>((ref) => null);

// === State untuk Pilihan Opsional ===

// Menyimpan status checkbox gambar optional
final showGambarOptionalProvider = StateProvider<bool>((ref) => false);

// Menyimpan ID gambar optional yang dipilih
final gambarOptionalIdProvider = StateProvider<int?>((ref) => null);

// Menyimpan status checkbox gambar kelistrikan
final showGambarKelistrikanProvider = StateProvider<bool>((ref) => false);

// Menyimpan ID gambar kelistrikan yang dipilih
final gambarKelistrikanIdProvider = StateProvider<int?>((ref) => null);

// === State untuk Baris Gambar Utama yang Dinamis ===

// Tipe data untuk merepresentasikan satu baris pilihan
class GambarUtamaSelection {
  final int? judulId; // Ganti dari 'String? judul'
  final int? varianBodyId;

  GambarUtamaSelection({this.judulId, this.varianBodyId});

  GambarUtamaSelection copyWith({int? judulId, int? varianBodyId}) {
    return GambarUtamaSelection(
      judulId: judulId ?? this.judulId,
      varianBodyId: varianBodyId ?? this.varianBodyId,
    );
  }
}

// Provider ini akan menyimpan list dari pilihan di setiap baris
final gambarUtamaSelectionProvider =
    StateNotifierProvider<
      GambarUtamaSelectionNotifier,
      List<GambarUtamaSelection>
    >((ref) {
      final jumlah = ref.watch(jumlahGambarProvider);
      return GambarUtamaSelectionNotifier(jumlah);
    });

class GambarUtamaSelectionNotifier
    extends StateNotifier<List<GambarUtamaSelection>> {
  GambarUtamaSelectionNotifier(int initialSize)
    : super(List.generate(initialSize, (_) => GambarUtamaSelection()));

  void updateSelection(int index, {int? judulId, int? varianBodyId}) {
    // Ganti 'String? judul'
    if (index < 0 || index >= state.length) return;

    final newList = List<GambarUtamaSelection>.from(state);
    newList[index] = newList[index].copyWith(
      judulId: judulId,
      varianBodyId: varianBodyId,
    );
    state = newList;
  }

  void resize(int newSize) {
    if (newSize == state.length) return;

    final currentList = List<GambarUtamaSelection>.from(state);
    if (newSize > state.length) {
      currentList.addAll(
        List.generate(newSize - state.length, (_) => GambarUtamaSelection()),
      );
    } else {
      currentList.removeRange(newSize, state.length);
    }
    state = currentList;
  }
}

final judulGambarOptionsProvider = FutureProvider<List<OptionItem>>((
  ref,
) async {
  // --- UBAH STRING MENJADI KONSTANTA ---
  final response = await ref
      .watch(apiClientProvider)
      .dio
      .get(ApiEndpoints.judulGambar);
  // ------------------------------------

  final List<dynamic> data = response.data;
  return data
      .map((item) => OptionItem.fromJson(item, nameKey: 'name'))
      .toList();
});

// === Provider untuk mengambil data dropdown dari API ===

// Provider untuk dropdown pemeriksa
final pemeriksaOptionsProvider = FutureProvider<List<OptionItem>>((ref) async {
  // Anda perlu menambahkan endpoint ini di ApiEndpoints.dart
  // static const String pemeriksa = '/options/users/pemeriksa';
  final response = await ref
      .watch(apiClientProvider)
      .dio
      .get('/options/users/pemeriksa');
  final List<dynamic> data = response.data;
  return data
      .map((item) => OptionItem.fromJson(item, nameKey: 'name'))
      .toList();
});

// Provider untuk dropdown varian body (tergantung jenis kendaraan)
final varianBodyOptionsFamilyProvider =
    FutureProvider.family<List<OptionItem>, String>((
      ref,
      jenisKendaraanId,
    ) async {
      final response = await ref
          .watch(apiClientProvider)
          .dio
          .get('/options/varian-body/$jenisKendaraanId');
      final List<dynamic> data = response.data;
      return data
          .map((item) => OptionItem.fromJson(item, nameKey: 'varian_body'))
          .toList();
    });

// Anda juga perlu endpoint untuk gambar optional dan kelistrikan di ApiEndpoints.dart
// static const String gambarOptional = '/options/gambar-optional';
// static String gambarKelistrikan(String chassisId) => '/options/gambar-kelistrikan/$chassisId';

final gambarOptionalOptionsProvider = FutureProvider<List<OptionItem>>((
  ref,
) async {
  final response = await ref
      .watch(apiClientProvider)
      .dio
      .get('/options/gambar-optional');
  final List<dynamic> data = response.data;
  return data
      .map((item) => OptionItem.fromJson(item, nameKey: 'deskripsi'))
      .toList();
});

final gambarKelistrikanOptionsFamilyProvider =
    FutureProvider.family<List<OptionItem>, String>((ref, chassisId) async {
      final response = await ref
          .watch(apiClientProvider)
          .dio
          .get('/options/gambar-kelistrikan/$chassisId');
      final List<dynamic> data = response.data;
      return data
          .map((item) => OptionItem.fromJson(item, nameKey: 'deskripsi'))
          .toList();
    });
