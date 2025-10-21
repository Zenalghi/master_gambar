import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import '../../../app/core/providers.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/paginated_response.dart';

final userRepositoryProvider = Provider((ref) => UserRepository(ref));

class UserRepository {
  final Ref _ref;
  UserRepository(this._ref);

  Future<PaginatedResponse<AppUser>> getUsers({
    required int page,
    required int rowsPerPage,
    required String sortBy,
    required bool sortAscending,
    String? searchQuery,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get(
          '/admin/users',
          queryParameters: {
            'page': page,
            'per_page': rowsPerPage,
            'sort_by': sortBy,
            'sort_asc': sortAscending
                .toString(), // Kirim sebagai string 'true'/'false'
            if (searchQuery != null && searchQuery.isNotEmpty)
              'search': searchQuery,
          },
        );
    // Parse response menggunakan PaginatedResponse
    return PaginatedResponse.fromJson(response.data, AppUser.fromJson);
  }
  // --- AKHIR PERUBAHAN ---

  // POST a new user
  Future<AppUser> addUser({
    required String name,
    required String username,
    required String password,
    required int roleId,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .post(
          '/admin/users',
          data: {
            'name': name,
            'username': username,
            'password': password,
            'password_confirmation': password,
            'role_id': roleId,
          },
        );
    return AppUser.fromJson(response.data);
  }

  // PUT an existing user
  Future<AppUser> updateUser({
    required int id,
    required String name,
    required String username,
    required int roleId,
    String? password,
  }) async {
    final data = {'name': name, 'username': username, 'role_id': roleId};

    if (password != null && password.isNotEmpty) {
      data['password'] = password;
      data['password_confirmation'] = password;
    }

    final response = await _ref
        .read(apiClientProvider)
        .dio
        .put('/admin/users/$id', data: data);
    return AppUser.fromJson(response.data);
  }

  // DELETE a user
  Future<void> deleteUser({required int id}) async {
    await _ref.read(apiClientProvider).dio.delete('/admin/users/$id');
  }

  // POST user signature file
  Future<AppUser> uploadSignature({
    required int userId,
    required File signatureFile,
  }) async {
    final fileName = signatureFile.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'paraf': await MultipartFile.fromFile(
        signatureFile.path,
        filename: fileName,
        contentType: MediaType('image', 'png'),
      ),
    });

    final response = await _ref
        .read(apiClientProvider)
        .dio
        .post('/admin/users/$userId/paraf', data: formData);
    return AppUser.fromJson(response.data);
  }
}
