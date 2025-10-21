import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/paginated_response.dart';
import '../../../app/core/providers.dart';
import '../../../data/models/customer.dart';
import 'package:http_parser/http_parser.dart';

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
            'sort_asc': sortAscending
                .toString(), // Kirim sebagai string 'true'/'false'
            if (searchQuery != null && searchQuery.isNotEmpty)
              'search': searchQuery,
          },
        );
    // Parse response menggunakan PaginatedResponse
    return PaginatedResponse.fromJson(response.data, Customer.fromJson);
  }
  // --- AKHIR PERUBAHAN ---

  // POST a new customer
  Future<Customer> addCustomer({
    required String namaPt,
    required String pj,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .post('/admin/customers', data: {'nama_pt': namaPt, 'pj': pj});
    return Customer.fromJson(response.data);
  }

  // PUT an existing customer
  Future<Customer> updateCustomer({
    required int id,
    required String namaPt,
    required String pj,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .put('/admin/customers/$id', data: {'nama_pt': namaPt, 'pj': pj});
    return Customer.fromJson(response.data);
  }

  // DELETE a customer
  Future<void> deleteCustomer({required int id}) async {
    await _ref.read(apiClientProvider).dio.delete('/admin/customers/$id');
  }

  // POST signature file
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
}
