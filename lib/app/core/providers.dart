// File: lib/app/core/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../elements/auth/repository/auth_repository.dart';

// Provider untuk AuthRepository (tidak berubah)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// StateProvider untuk role pengguna (tidak berubah)
final userRoleProvider = StateProvider<String?>((ref) => null);

// --- TAMBAHAN BARU ---
// StateProvider untuk menyimpan nama pengguna secara aktif
final userNameProvider = StateProvider<String?>((ref) => null);
// --------------------

// FutureProvider untuk pengecekan awal (sekarang juga memuat nama)
final initialAuthProvider = FutureProvider<String?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  
  if (token != null) {
    // Jika token ada, inisialisasi state role dan nama
    final role = prefs.getString('user_role');
    final name = prefs.getString('user_name'); // Ambil nama
    ref.read(userRoleProvider.notifier).state = role;
    ref.read(userNameProvider.notifier).state = name; // Simpan nama ke state
  }
  
  return token;
});