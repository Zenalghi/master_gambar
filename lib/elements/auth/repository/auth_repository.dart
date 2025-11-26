// File: lib/elements/auth/repository/auth_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/elements/home/providers/page_state_provider.dart';
import 'package:master_gambar/elements/home/providers/transaksi_providers.dart';
import 'package:master_gambar/elements/home/providers/input_gambar_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/providers/api_client.dart';
import '../../../app/core/providers.dart';

class AuthRepository {
  // final ApiClient _apiClient = ApiClient();
  final ApiClient _apiClient;
  AuthRepository(this._apiClient);

  Future<void> login(String username, String password, WidgetRef ref) async {
    try {
      final response = await _apiClient.dio.post(
        '/login',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        final user = response.data['user'];
        final userRole = user['role']['name'];
        final userName = user['name'];
        final userId = user['id']; // Ambil nama dari response

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_role', userRole);
        await prefs.setString('user_name', userName); // Simpan nama
        await prefs.setInt('user_id', userId);

        // Update kedua StateProvider
        ref.read(authTokenProvider.notifier).state = token;
        ref.read(userRoleProvider.notifier).state = userRole;
        ref.read(userNameProvider.notifier).state = userName;
        ref.read(currentUserIdProvider.notifier).state = userId;
      } else {
        throw Exception('Failed to login');
      }
    } on DioException catch (e) {
      throw Exception('Error: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<void> logout(WidgetRef ref) async {
    // 1. Hapus data dari penyimpanan lokal
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await prefs.remove('user_name');
    await prefs.remove('user_id');

    // 2. Reset provider otentikasi
    ref.read(authTokenProvider.notifier).state =
        null; // Penting untuk transaksi histori
    ref.read(userRoleProvider.notifier).state = null;
    ref.read(userNameProvider.notifier).state = null;
    ref.read(currentUserIdProvider.notifier).state = null;

    // 3. Reset state navigasi & tabel
    ref.read(pageStateProvider.notifier).state = PageState(pageIndex: 0);

    // 5. Reset semua state form Tambah Transaksi
    // ref.invalidate(customerOptionsProvider);
    ref.invalidate(typeEngineOptionsProvider);
    ref.invalidate(jenisPengajuanOptionsProvider);

    // 6. Reset semua state form Input Gambar
    // ref.read(pemeriksaIdProvider.notifier).state = null;
    ref.read(showGambarOptionalProvider.notifier).state = false;
    ref.read(jumlahGambarOptionalProvider.notifier).state = 1;
    ref.invalidate(gambarOptionalSelectionProvider);
    ref.invalidate(gambarUtamaSelectionProvider);
    ref.invalidate(pemeriksaOptionsProvider);
    ref.invalidate(judulGambarOptionsProvider);
    ref.invalidate(gambarOptionalOptionsProvider);
  }
}
