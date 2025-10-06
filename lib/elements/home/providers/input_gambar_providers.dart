import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:master_gambar/app/core/providers.dart';
import 'package:master_gambar/data/models/option_item.dart';
import 'package:master_gambar/data/providers/api_endpoints.dart';

// Provider untuk melacak status loading/processing
final isProcessingProvider = StateProvider<bool>((ref) => false);

// === State untuk Pilihan Utama ===
// Provider 'jumlahGambarProvider' telah dihapus dari sini.
final jumlahGambarProvider = StateProvider<int>((ref) => 1);

// Menyimpan ID pemeriksa yang dipilih
final pemeriksaIdProvider = StateProvider<int?>((ref) => null);

// === State untuk Pilihan Opsional ===
final showGambarOptionalProvider = StateProvider<bool>((ref) => false);
final jumlahGambarOptionalProvider = StateProvider<int>((ref) => 1);

class GambarOptionalSelection {
  final int? gambarOptionalId;
  GambarOptionalSelection({this.gambarOptionalId});
}

final gambarOptionalSelectionProvider =
    StateNotifierProvider<
      GambarOptionalSelectionNotifier,
      List<GambarOptionalSelection>
    >((ref) {
      final jumlah = ref.watch(jumlahGambarOptionalProvider);
      return GambarOptionalSelectionNotifier(jumlah);
    });

class GambarOptionalSelectionNotifier
    extends StateNotifier<List<GambarOptionalSelection>> {
  GambarOptionalSelectionNotifier(int initialSize)
    : super(List.generate(initialSize, (_) => GambarOptionalSelection()));

  void updateSelection(int index, {int? gambarOptionalId}) {
    if (index < 0 || index >= state.length) return;
    final newList = List<GambarOptionalSelection>.from(state);
    newList[index] = GambarOptionalSelection(
      gambarOptionalId: gambarOptionalId,
    );
    state = newList;
  }

  void resize(int newSize) {
    state = List.generate(
      newSize,
      (i) => i < state.length ? state[i] : GambarOptionalSelection(),
    );
  }
}

final showGambarKelistrikanProvider = StateProvider<bool>((ref) => false);
final gambarKelistrikanIdProvider = StateProvider<int?>((ref) => null);

// === State untuk Baris Gambar Utama yang Dinamis ===
class GambarUtamaSelection {
  final int? judulId;
  final int? varianBodyId;

  GambarUtamaSelection({this.judulId, this.varianBodyId});

  GambarUtamaSelection copyWith({int? judulId, int? varianBodyId}) {
    return GambarUtamaSelection(
      judulId: judulId ?? this.judulId,
      varianBodyId: varianBodyId ?? this.varianBodyId,
    );
  }
}

// --- PERBAIKAN DI SINI ---
// Provider ini tidak lagi me-watch provider lain. Ia akan dimulai dengan
// ukuran default dan diubah ukurannya oleh UI.
final gambarUtamaSelectionProvider =
    StateNotifierProvider<
      GambarUtamaSelectionNotifier,
      List<GambarUtamaSelection>
    >((ref) {
      // Mulai dengan ukuran default 1.
      return GambarUtamaSelectionNotifier(1);
    });
// -------------------------

class GambarUtamaSelectionNotifier
    extends StateNotifier<List<GambarUtamaSelection>> {
  GambarUtamaSelectionNotifier(int initialSize)
    : super(List.generate(initialSize, (_) => GambarUtamaSelection()));

  void updateSelection(int index, {int? judulId, int? varianBodyId}) {
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

// === Provider untuk mengambil data dropdown dari API ===
final judulGambarOptionsProvider = FutureProvider<List<OptionItem>>((
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

final pemeriksaOptionsProvider = FutureProvider<List<OptionItem>>((ref) async {
  final response = await ref
      .watch(apiClientProvider)
      .dio
      .get('/options/users/pemeriksa');
  final List<dynamic> data = response.data;
  return data
      .map((item) => OptionItem.fromJson(item, nameKey: 'name'))
      .toList();
});

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

final gambarOptionalOptionsProvider = FutureProvider<List<OptionItem>>((
  ref,
) async {
  // 1. Awasi (watch) pilihan yang dibuat di baris-baris Gambar Utama
  final utamaSelections = ref.watch(gambarUtamaSelectionProvider);

  // 2. Ekstrak semua ID Varian Body yang telah dipilih,
  //    hapus duplikat dan nilai null.
  final selectedVarianIds = utamaSelections
      .map((s) => s.varianBodyId)
      .where((id) => id != null)
      .toSet() // toSet() secara otomatis menghapus duplikat
      .toList();

  // 3. Jika tidak ada Varian Body yang dipilih, kembalikan daftar kosong.
  if (selectedVarianIds.isEmpty) {
    return [];
  }

  // 4. Panggil endpoint BARU dengan membawa daftar ID sebagai parameter query
  // File: lib/elements/home/providers/input_gambar_providers.dart

  // ...
  final response = await ref
      .watch(apiClientProvider)
      .dio
      .post(
        // <-- Ubah ke .post
        ApiEndpoints.gambarOptionalByVarian,
        data: {
          // <-- Ubah ke data
          'varian_ids': selectedVarianIds,
        },
      );
  // ...

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

final dependentOptionalOptionsProvider = FutureProvider<List<OptionItem>>((
  ref,
) async {
  // 1. Awasi pilihan di baris-baris Gambar Utama
  final utamaSelections = ref.watch(gambarUtamaSelectionProvider);

  // 2. Kumpulkan semua ID Varian Body yang unik dan tidak null
  final selectedVarianIds = utamaSelections
      .map((s) => s.varianBodyId)
      .where((id) => id != null)
      .toSet()
      .toList();

  // 3. Jika tidak ada yang dipilih, kembalikan daftar kosong
  if (selectedVarianIds.isEmpty) {
    return [];
  }

  // 4. Panggil endpoint baru dengan metode POST
  final response = await ref
      .watch(apiClientProvider)
      .dio
      .post(
        '/options/dependent-optionals', // Endpoint baru
        data: {'varian_ids': selectedVarianIds},
      );

  final List<dynamic> data = response.data;
  return data
      .map((item) => OptionItem.fromJson(item, nameKey: 'deskripsi'))
      .toList();
});

final activeDependentOptionalIdsProvider = Provider<List<int>>((ref) {
  // Awasi provider yang mengambil data dependen
  final dependentOptionalsAsync = ref.watch(dependentOptionalOptionsProvider);

  // Jika datanya ada, ambil semua ID-nya. Jika tidak, kembalikan list kosong.
  return dependentOptionalsAsync.when(
    data: (items) => items.map((item) => item.id as int).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});
