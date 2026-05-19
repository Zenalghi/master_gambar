// lib/admin/management/repository/customer_repository.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import '../../../data/models/customer.dart';
import '../../../app/core/providers.dart';
import '../../../data/models/paginated_response.dart';

final customerRepositoryProvider = Provider((ref) => CustomerRepository(ref));

class CustomerRepository {
  final Ref _ref;
  CustomerRepository(this._ref);

  Future<PaginatedResponse<Customer>> getCustomers({
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
          '/admin/customers',
          queryParameters: {
            'page': page,
            'per_page': rowsPerPage,
            'sort_by': sortBy,
            'sort_asc': sortAscending.toString(),
            if (searchQuery != null && searchQuery.isNotEmpty)
              'search': searchQuery,
          },
        );
    // Parse response menggunakan PaginatedResponse
    return PaginatedResponse.fromJson(response.data, Customer.fromJson);
  }

  Future<Customer> addCustomer({
    required String namaPt,
    required String pj,
    String? namaDrafter,
    String? namaPemeriksa,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .post(
          '/admin/customers',
          data: {
            'nama_pt': namaPt,
            'pj': pj,
            'nama_drafter': namaDrafter,
            'nama_pemeriksa': namaPemeriksa,
          },
        );
    return Customer.fromJson(response.data);
  }

  // --- PERUBAHAN: Tambah parameter drafter & pemeriksa ---
  Future<Customer> updateCustomer({
    required int id,
    required String namaPt,
    required String pj,
    String? namaDrafter,
    String? namaPemeriksa,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .put(
          '/admin/customers/$id',
          data: {
            'nama_pt': namaPt,
            'pj': pj,
            'nama_drafter': namaDrafter,
            'nama_pemeriksa': namaPemeriksa,
          },
        );
    return Customer.fromJson(response.data);
  }

  // DELETE a customer
  Future<void> deleteCustomer({required int id}) async {
    await _ref.read(apiClientProvider).dio.delete('/admin/customers/$id');
  }

  // Upload Paraf PJ
  Future<Customer> uploadSignature({
    required int customerId,
    required File signatureFile,
  }) async {
    final fileName = signatureFile.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'paraf_pj': await MultipartFile.fromFile(
        signatureFile.path,
        filename: fileName,
        contentType: MediaType('image', 'png'),
      ),
    });

    final response = await _ref
        .read(apiClientProvider)
        .dio
        .post('/admin/customers/$customerId/paraf', data: formData);
    return Customer.fromJson(response.data);
  }

  // --- TAMBAHAN: Upload Paraf Drafter ---
  Future<Customer> uploadSignatureDrafter({
    required int customerId,
    required File signatureFile,
  }) async {
    final fileName = signatureFile.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'paraf_drafter': await MultipartFile.fromFile(
        signatureFile.path,
        filename: fileName,
        contentType: MediaType('image', 'png'),
      ),
    });

    // PERBAIKAN: Gunakan endpoint /paraf
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .post('/admin/customers/$customerId/paraf', data: formData);
    return Customer.fromJson(response.data);
  }

  // --- TAMBAHAN: Upload Paraf Pemeriksa ---
  Future<Customer> uploadSignaturePemeriksa({
    required int customerId,
    required File signatureFile,
  }) async {
    final fileName = signatureFile.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'paraf_pemeriksa': await MultipartFile.fromFile(
        signatureFile.path,
        filename: fileName,
        contentType: MediaType('image', 'png'),
      ),
    });

    // PERBAIKAN: Gunakan endpoint /paraf
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .post('/admin/customers/$customerId/paraf', data: formData);
    return Customer.fromJson(response.data);
  }
}
