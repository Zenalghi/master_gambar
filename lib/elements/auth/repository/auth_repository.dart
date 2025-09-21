import 'package:dio/dio.dart'; // Jangan lupa import
import '../../../data/providers/api_client.dart'; // Import ApiClient

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  // Method untuk login
  Future<String> login(String username, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/login', // Endpoint login
        data: {
          'username': username,
          'password': password,
        },
      );

      // Jika berhasil, ambil dan kembalikan token
      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        // TODO: Simpan token ke SharedPreferences di sini
        return token;
      } else {
        throw Exception('Failed to login');
      }
    } on DioException catch (e) {
      // Handle error dari Dio (misal: koneksi, 401 Unauthorized)
      throw Exception('Error: ${e.response?.data['message'] ?? e.message}');
    }
  }
}