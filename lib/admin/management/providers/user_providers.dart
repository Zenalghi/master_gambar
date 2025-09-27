import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:master_gambar/app/core/providers.dart';
import 'package:master_gambar/data/models/app_user.dart';
import 'package:master_gambar/data/models/option_item.dart';
import 'package:master_gambar/data/providers/api_endpoints.dart';
import '../repository/user_repository.dart';

// Provider untuk mengambil daftar user
final userListProvider = FutureProvider<List<AppUser>>((ref) {
  return ref.watch(userRepositoryProvider).getUsers();
});

// Provider untuk mengambil daftar role (untuk dropdown)
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

// Provider untuk state tabel
final userSearchQueryProvider = StateProvider<String>((ref) => '');
final userRowsPerPageProvider = StateProvider<int>((ref) => 10);
