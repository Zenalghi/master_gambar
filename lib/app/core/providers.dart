// File: lib/app/core/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../elements/auth/repository/auth_repository.dart';


// Provider untuk AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// StateProvider untuk menyimpan role pengguna secara aktif.
// Ini adalah KUNCI dari solusi kita.
final userRoleProvider = StateProvider<String?>((ref) => null);

// FutureProvider untuk mengecek token awal saat aplikasi dibuka.
// Ini hanya berjalan sekali.
final initialAuthProvider = FutureProvider<String?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  if (token != null) {
    // Jika token ada, kita inisialisasi state role pengguna
    final role = prefs.getString('user_role');
    ref.read(userRoleProvider.notifier).state = role;
  }

  return token;
});
