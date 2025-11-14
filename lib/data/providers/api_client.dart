// File: lib/data/providers/api_client.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // 1. Definisikan URL dasar di sini. Inilah satu-satunya tempat Anda perlu mengubahnya nanti.
  static const String baseUrl = 'http://master-gambar.test';

  final Dio dio;

  ApiClient(String baseUrl) 
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }
}
