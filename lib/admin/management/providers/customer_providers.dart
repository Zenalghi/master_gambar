import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:master_gambar/data/models/customer.dart';
import '../repository/customer_repository.dart';

// Provider untuk mengambil dan men-cache daftar customer
final customerListProvider = FutureProvider<List<Customer>>((ref) {
  return ref.watch(customerRepositoryProvider).getCustomers();
});

// Provider untuk state tabel (pencarian, baris per halaman, dll)
final customerSearchQueryProvider = StateProvider<String>((ref) => '');
final customerRowsPerPageProvider = StateProvider<int>((ref) => 25);
