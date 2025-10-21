import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/customer.dart';
import '../repository/customer_repository.dart';

// 1. Definisikan State untuk tabel customer
class CustomerDataTableState {
  final bool isLoading;
  final List<Customer> customers;
  final int totalRecords;
  final String? error;

  CustomerDataTableState({
    this.isLoading = true,
    this.customers = const [],
    this.totalRecords = 0,
    this.error,
  });

  CustomerDataTableState copyWith({
    bool? isLoading,
    List<Customer>? customers,
    int? totalRecords,
    String? error,
  }) {
    return CustomerDataTableState(
      isLoading: isLoading ?? this.isLoading,
      customers: customers ?? this.customers,
      totalRecords: totalRecords ?? this.totalRecords,
      error: error ?? this.error,
    );
  }
}

// 2. Buat Notifier untuk mengelola state
class CustomerNotifier extends StateNotifier<CustomerDataTableState> {
  final Ref _ref;
  Timer? _debounce;

  CustomerNotifier(this._ref) : super(CustomerDataTableState());

  Future<void> getCustomers({
    required int page,
    required int rowsPerPage,
    required String sortBy,
    required bool sortAscending,
    String? searchQuery,
  }) async {
    // Set loading true hanya jika data belum ada (first load)
    if (state.customers.isEmpty) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      // Jika data sudah ada, jangan tampilkan loading fullscreen,
      // UI akan menanganinya (misal: tombol refresh berputar)
      state = state.copyWith(error: null);
    }

    try {
      final response = await _ref
          .read(customerRepositoryProvider)
          .getCustomers(
            page: page,
            rowsPerPage: rowsPerPage,
            sortBy: sortBy,
            sortAscending: sortAscending,
            searchQuery: searchQuery,
          );
      state = state.copyWith(
        isLoading: false,
        customers: response.data,
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
      _ref.read(customerSearchQueryProvider.notifier).state = query;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

// 3. Definisikan Provider utama
final customerNotifierProvider =
    StateNotifierProvider<CustomerNotifier, CustomerDataTableState>(
      (ref) => CustomerNotifier(ref),
    );

// 4. Provider untuk state pencarian
final customerSearchQueryProvider = StateProvider<String>((ref) => '');

// 5. Provider untuk memicu refresh data
// UI akan watch provider ini. Saat ada create/update/delete,
// kita panggil ref.invalidate(customerInvalidator)
// Ini akan membuat provider di-rebuild dan memicu ref.listen di UI.
final customerInvalidator = StateProvider<int>((ref) => 0);
