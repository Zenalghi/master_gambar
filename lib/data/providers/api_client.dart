// File: lib/data/providers/api_client.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Dio dio;

  ApiClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: 'http://master-gambar.test/api', // URL base backend Anda
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    // Ini adalah Interceptor-nya
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Baca token dari SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');

          // Jika token ada, tambahkan ke header
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options); // Lanjutkan request
        },
      ),
    );
  }
}