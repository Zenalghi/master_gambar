import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../app/core/providers.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/option_item.dart';
import '../../../data/providers/api_endpoints.dart';
import '../repository/user_repository.dart';

// 1. Definisikan State untuk tabel user
class UserDataTableState {
  final bool isLoading;
  final List<AppUser> users;
  final int totalRecords;
  final String? error;

  UserDataTableState({
    this.isLoading = true,
    this.users = const [],
    this.totalRecords = 0,
    this.error,
  });

  UserDataTableState copyWith({
    bool? isLoading,
    List<AppUser>? users,
    int? totalRecords,
    String? error,
  }) {
    return UserDataTableState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      totalRecords: totalRecords ?? this.totalRecords,
      error: error ?? this.error,
    );
  }
}

// 2. Buat Notifier untuk mengelola state
class UserNotifier extends StateNotifier<UserDataTableState> {
  final Ref _ref;
  Timer? _debounce;

  UserNotifier(this._ref) : super(UserDataTableState());

  Future<void> getUsers({
    required int page,
    required int rowsPerPage,
    required String sortBy,
    required bool sortAscending,
    String? searchQuery,
  }) async {
    if (state.users.isEmpty) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(error: null);
    }

    try {
      final response = await _ref
          .read(userRepositoryProvider)
          .getUsers(
            page: page,
            rowsPerPage: rowsPerPage,
            sortBy: sortBy,
            sortAscending: sortAscending,
            searchQuery: searchQuery,
          );
      state = state.copyWith(
        isLoading: false,
        users: response.data,
        totalRecords: response.total,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Method untuk handle pencarian dengan debounce
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _ref.read(userSearchQueryProvider.notifier).state = query;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

// 3. Definisikan Provider utama
final userNotifierProvider =
    StateNotifierProvider<UserNotifier, UserDataTableState>(
      (ref) => UserNotifier(ref),
    );

// 4. Provider untuk state pencarian
final userSearchQueryProvider = StateProvider<String>((ref) => '');

// 5. Provider untuk memicu refresh data
final userInvalidator = StateProvider<int>((ref) => 0);

// 6. Provider untuk dropdown role (ini tidak berubah)
final roleOptionsProvider = FutureProvider<List<OptionItem>>((ref) async {
  final response = await ref
      .watch(apiClientProvider)
      .dio
      .get(ApiEndpoints.roles);
  final List<dynamic> data = response.data;
  return data
      .map((item) => OptionItem.fromJson(item, nameKey: 'name'))
      .toList();
});
