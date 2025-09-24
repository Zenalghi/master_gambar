// File: lib/elements/auth/repository/auth_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/providers/api_client.dart';
import '../../../app/core/providers.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

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
        final userName = user['name']; // Ambil nama dari response

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_role', userRole);
        await prefs.setString('user_name', userName); // Simpan nama

        // Update kedua StateProvider
        ref.read(userRoleProvider.notifier).state = userRole;
        ref.read(userNameProvider.notifier).state = userName;
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
    await prefs.remove('user_name'); // Hapus nama saat logout

    // Reset kedua StateProvider
    ref.read(userRoleProvider.notifier).state = null;
    ref.read(userNameProvider.notifier).state = null;
  }
}
