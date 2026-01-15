//lib\elements\home\providers\input_gambar_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:master_gambar/app/core/providers.dart';
import 'package:master_gambar/data/models/option_item.dart';
import 'package:master_gambar/data/providers/api_endpoints.dart';
import '../../../app/core/notifiers/refresh_notifier.dart';
import '../repository/options_repository.dart';

// import 'package:equatable/equatable.dart';
// Provider untuk menyimpan Info Kelistrikan yang sudah di-fetch di screen
final kelistrikanInfoProvider = StateProvider<Map<String, dynamic>?>(
  (ref) => null,
);

class VarianFilterParams {
  final String search;
  final int? masterDataId;

  VarianFilterParams({required this.search, this.masterDataId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VarianFilterParams &&
          runtimeType == other.runtimeType &&
          search == other.search &&
          masterDataId == other.masterDataId;

  @override
  int get hashCode => search.hashCode ^ masterDataId.hashCode;
}

// Provider untuk melacak status loading/processing
final isProcessingProvider = StateProvider<bool>((ref) => false);

// === State untuk Pilihan Utama ===
final deskripsiOptionalProvider = StateProvider<String>((ref) => '');

final jumlahGambarProvider = StateProvider<int>((ref) => 1);

// Menyimpan ID pemeriksa yang dipilih
final pemeriksaIdProvider = StateProvider<int?>((ref) => null);

class GambarOptionalSelection {
  final int? gambarOptionalId;
  GambarOptionalSelection({this.gambarOptionalId});
}

// 1. Buat Class State baru untuk menampung dua list
class IndependentListState {
  final List<OptionItem> activeItems;
  final List<OptionItem> hiddenItems;

  IndependentListState({
    this.activeItems = const [],
    this.hiddenItems = const [],
  });

  IndependentListState copyWith({
    List<OptionItem>? activeItems,
    List<OptionItem>? hiddenItems,
  }) {
    return IndependentListState(
      activeItems: activeItems ?? this.activeItems,
      hiddenItems: hiddenItems ?? this.hiddenItems,
    );
  }
}

// 2. Update Provider Definition
final independentListNotifierProvider =
    StateNotifierProvider<
      IndependentListNotifier,
      AsyncValue<IndependentListState>
    >((ref) {
      return IndependentListNotifier(ref);
    });

// 3. Update Notifier Logic
class IndependentListNotifier
    extends StateNotifier<AsyncValue<IndependentListState>> {
  final Ref ref;

  IndependentListNotifier(this.ref) : super(const AsyncValue.loading());

  // Simpan data master mentah untuk referensi
  List<OptionItem> _allMasterItems = [];

  Future<void> fetchByMasterData(int masterDataId) async {
    state = const AsyncValue.loading();
    try {
      final response = await ref
          .read(apiClientProvider)
          .dio
          .get('/options/independent-images/$masterDataId');

      final List<dynamic> data = response.data;
      _allMasterItems = data
          .map((item) => OptionItem.fromJson(item, nameKey: 'name'))
          .toList();

      // Default: Semua masuk ke Active Items
      state = AsyncValue.data(
        IndependentListState(
          activeItems: List.from(_allMasterItems),
          hiddenItems: [],
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Apply Saved Order (Logic Baru: Memisahkan Active vs Hidden berdasarkan ID yang disimpan)
  void applySavedOrder(List<int> savedIds) {
    if (_allMasterItems.isEmpty) return;

    // 1. Filter Active Items (Yang ada di savedIds)
    // Kita harus menjaga urutan sesuai savedIds
    final List<OptionItem> newActive = [];
    for (var id in savedIds) {
      final found = _allMasterItems.where((e) => e.id == id).firstOrNull;
      if (found != null) {
        newActive.add(found);
      }
    }

    // 2. Filter Hidden Items (Yang TIDAK ada di savedIds)
    final newHidden = _allMasterItems
        .where((e) => !savedIds.contains(e.id))
        .toList();

    state = AsyncValue.data(
      IndependentListState(activeItems: newActive, hiddenItems: newHidden),
    );
  }

  // Pindahkan dari Active ke Hidden
  void hideItem(OptionItem item) {
    state.whenData((currentState) {
      final newActive = List<OptionItem>.from(currentState.activeItems)
        ..remove(item);
      final newHidden = List<OptionItem>.from(currentState.hiddenItems)
        ..add(item);

      // Opsional: Sort hidden items by name agar rapi
      // newHidden.sort((a, b) => a.name.compareTo(b.name));

      state = AsyncValue.data(
        currentState.copyWith(activeItems: newActive, hiddenItems: newHidden),
      );
    });
  }

  // Pindahkan dari Hidden ke Active
  void unhideItem(OptionItem item) {
    state.whenData((currentState) {
      final newHidden = List<OptionItem>.from(currentState.hiddenItems)
        ..remove(item);
      final newActive = List<OptionItem>.from(currentState.activeItems)
        ..add(item); // Masuk ke paling bawah

      state = AsyncValue.data(
        currentState.copyWith(activeItems: newActive, hiddenItems: newHidden),
      );
    });
  }

  // Reorder hanya untuk Active Items
  void reorder(int oldIndex, int newIndex) {
    state.whenData((currentState) {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final newActive = List<OptionItem>.from(currentState.activeItems);
      final item = newActive.removeAt(oldIndex);
      newActive.insert(newIndex, item);

      state = AsyncValue.data(currentState.copyWith(activeItems: newActive));
    });
  }
}

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
    if (newSize == state.length) return;

    final currentList = List<GambarOptionalSelection>.from(state);

    if (newSize > state.length) {
      // Jika bertambah, COPY data lama, lalu tambahkan slot kosong baru
      currentList.addAll(
        List.generate(newSize - state.length, (_) => GambarOptionalSelection()),
      );
    } else {
      // Jika berkurang, potong dari belakang
      currentList.removeRange(newSize, state.length);
    }
    state = currentList;
  }
}

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
  ref.watch(refreshNotifierProvider);
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
  ref.watch(refreshNotifierProvider);
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
    FutureProvider.family<List<OptionItem>, int>((
      // <-- Ganti String ke int
      ref,
      masterDataId, // <-- Parameter sekarang masterDataId
    ) async {
      ref.watch(refreshNotifierProvider);
      // Kirim masterDataId ke endpoint
      final response = await ref
          .watch(apiClientProvider)
          .dio
          .get(ApiEndpoints.varianBody(masterDataId.toString()));

      final List<dynamic> data = response.data;
      return data
          .map((item) => OptionItem.fromJson(item, nameKey: 'varian_body'))
          .toList();
    });

final gambarOptionalOptionsProvider = FutureProvider<List<OptionItem>>((
  ref,
) async {
  ref.watch(refreshNotifierProvider);
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

final gambarKelistrikanDataProvider =
    FutureProvider.family<OptionItem?, String>((ref, chassisId) async {
      // Selalu dengarkan lonceng refresh
      ref.watch(refreshNotifierProvider);

      // Panggil endpoint yang sudah ada
      final response = await ref
          .watch(apiClientProvider)
          .dio
          .get('/options/gambar-kelistrikan/$chassisId');

      final List<dynamic> data = response.data;

      // Jika ada data, ambil yang pertama. Jika tidak, kembalikan null.
      if (data.isNotEmpty) {
        return OptionItem.fromJson(data.first, nameKey: 'deskripsi');
      }
      return null;
    });

final dependentOptionalOptionsProvider = FutureProvider<List<OptionItem>>((
  ref,
) async {
  ref.watch(refreshNotifierProvider);

  // 1. Awasi pilihan di baris-baris Gambar Utama
  final utamaSelections = ref.watch(gambarUtamaSelectionProvider);

  // 2. Kumpulkan data Varian DAN Judul secara berurutan
  // Kita perlu list yang sinkron, jadi jangan pakai toSet/unique sembarangan jika urutan index penting
  // Tapi API kita loop berdasarkan index input, jadi kita kirim array mentah yang valid.

  final validSelections = utamaSelections
      .where((s) => s.varianBodyId != null)
      .toList();

  if (validSelections.isEmpty) {
    return [];
  }

  final List<int> varianIds = validSelections
      .map((s) => s.varianBodyId!)
      .toList();
  // Kirim Judul ID (bisa null jika user belum pilih judul)
  final List<int?> judulIds = validSelections.map((s) => s.judulId).toList();

  // 3. Panggil endpoint dengan parameter lengkap
  final response = await ref
      .read(apiClientProvider)
      .dio
      .post(
        '/options/dependent-optionals',
        data: {
          'varian_ids': varianIds,
          'judul_ids': judulIds, // Kirim ini
        },
      );

  final List<dynamic> data = response.data;
  // UI otomatis akan menampilkan nama baru karena OptionItem mengambil key 'deskripsi' yang sudah diubah backend
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
// Provider Varian Body Searchable dengan Status
final varianBodyStatusOptionsProvider =
    FutureProvider.family<List<OptionItem>, VarianFilterParams>((
      ref,
      params,
    ) async {
      // Panggil repository dengan kedua parameter
      return ref
          .read(optionsRepositoryProvider)
          .getVarianBodyWithStatus(
            params.search,
            masterDataId: params.masterDataId,
          );
    });
final isLoadingKelistrikanProvider = StateProvider<bool>((ref) => false);
// Default true (mode edit aktif/bisa ngetik)
final isEditModeProvider = StateProvider.autoDispose<bool>((ref) => true);
