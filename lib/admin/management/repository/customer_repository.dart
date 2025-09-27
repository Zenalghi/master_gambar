import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart'; // Pastikan import ini ada
import 'package:master_gambar/app/core/providers.dart';
import 'package:master_gambar/data/models/customer.dart';

final customerRepositoryProvider = Provider((ref) => CustomerRepository(ref));

class CustomerRepository {
  final Ref _ref;
  CustomerRepository(this._ref);

  // GET all customers
  Future<List<Customer>> getCustomers() async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/admin/customers');
    final List<dynamic> data = response.data;
    return data.map((item) => Customer.fromJson(item)).toList();
  }

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
      // --- PERBAIKAN KUNCI (KEY) DI SINI ---
      'paraf_pj': await MultipartFile.fromFile(
        signatureFile.path,
        filename: fileName,
        contentType: MediaType('image', 'png'),
      ),

      // ------------------------------------
    });

    final response = await _ref
        .read(apiClientProvider)
        .dio
        .post('/admin/customers/$customerId/paraf', data: formData);
    return Customer.fromJson(response.data);
  }
}
