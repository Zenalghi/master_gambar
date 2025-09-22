// File: lib/elements/auth/repository/auth_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Import Riverpod
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/providers/api_client.dart';
import '../../../app/core/providers.dart'; // 2. Import file providers baru

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  // 3. Tambahkan Ref sebagai parameter agar bisa mengakses provider lain
  Future<void> login(String username, String password, WidgetRef ref) async {
    try {
      final response = await _apiClient.dio.post(
        '/login',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        final userRole = response.data['user']['role'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_role', userRole);

        // 4. Update StateProvider secara langsung setelah login berhasil
        ref.read(userRoleProvider.notifier).state = userRole;

      } else {
        throw Exception('Failed to login');
      }
    } on DioException catch (e) {
      throw Exception('Error: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<void> logout(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');

    // 5. Update StateProvider menjadi null saat logout
    ref.read(userRoleProvider.notifier).state = null;
  }
}