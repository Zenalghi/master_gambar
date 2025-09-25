// File: lib/app/core/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../elements/auth/repository/auth_repository.dart';
import '../../data/providers/api_client.dart'; // Import class ApiClient
import '../../elements/auth/auth_service.dart';

// Provider untuk instance ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Provider untuk AuthRepository (tidak berubah)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// StateProvider untuk role pengguna (tidak berubah)
final userRoleProvider = StateProvider<String?>((ref) => null);

// StateProvider untuk menyimpan nama pengguna secara aktif
final userNameProvider = StateProvider<String?>((ref) => null);
// FutureProvider untuk pengecekan awal (sekarang juga memuat nama)
final initialAuthProvider = FutureProvider<String?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  if (token != null) {
    // Jika token ada, inisialisasi state role dan nama
    final role = prefs.getString('user_role');
    final name = prefs.getString('user_name');
    final userId = prefs.getInt('user_id');
    ref.read(userRoleProvider.notifier).state = role;
    ref.read(userNameProvider.notifier).state = name;
    ref.read(currentUserIdProvider.notifier).state = userId;
  }

  return token;
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});
final currentUserIdProvider = StateProvider<int?>((ref) => null);
