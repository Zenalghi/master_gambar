// lib/admin/management/repository/document_customer_repository.dart
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/core/providers.dart';
import '../../../data/models/document_customer.dart';

final documentCustomerRepositoryProvider =
    Provider((ref) => DocumentCustomerRepository(ref));

class DocumentCustomerRepository {
  final Ref _ref;
  DocumentCustomerRepository(this._ref);

  Dio get _dio => _ref.read(apiClientProvider).dio;

  /// GET: Ambil document customer (semua user bisa akses)
  Future<DocumentCustomer?> getDocument(int customerId) async {
    try {
      final response = await _dio.get('/customers/$customerId/document');
      if (response.data == null ||
          response.data == '' ||
          response.data == 'null' ||
          (response.data is Map && (response.data as Map).isEmpty) ||
          (response.data is Map && (response.data as Map)['id'] == null)) {
        return null;
      }
      return DocumentCustomer.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  /// POST: Simpan / update document customer (admin only, multipart)
  Future<DocumentCustomer> saveDocument({
    required int customerId,
    PlatformFile? kopSuratFile,
    PlatformFile? dataUmumFile,
    List<PlatformFile>? newTdpFiles,
    String? tdpMasaBerlaku,
    String? permohonanSkrb,
    String? permohonanRekom,
    String? alamatPermohonan,
    String? bidangUsaha,
    String? alamatLengkap,
    bool removeKopSurat = false,
    bool removeDataUmum = false,
  }) async {
    final Map<String, dynamic> formDataMap = {};

    // Kop Surat
    if (kopSuratFile != null && kopSuratFile.bytes != null) {
      formDataMap['kop_surat'] = MultipartFile.fromBytes(
        kopSuratFile.bytes!,
        filename: kopSuratFile.name,
      );
    }
    if (removeKopSurat) formDataMap['remove_kop_surat'] = '1';

    // Data Umum
    if (dataUmumFile != null && dataUmumFile.bytes != null) {
      formDataMap['data_umum'] = MultipartFile.fromBytes(
        dataUmumFile.bytes!,
        filename: dataUmumFile.name,
      );
    }
    if (removeDataUmum) formDataMap['remove_data_umum'] = '1';

    // TDP Files (new files only)
    if (newTdpFiles != null && newTdpFiles.isNotEmpty) {
      final List<MultipartFile> tdpMultipartFiles = [];
      for (final f in newTdpFiles) {
        if (f.bytes != null) {
          tdpMultipartFiles.add(
            MultipartFile.fromBytes(f.bytes!, filename: f.name),
          );
        }
      }
      formDataMap['tdp_files[]'] = tdpMultipartFiles;
    }

    // Masa Berlaku
    if (tdpMasaBerlaku != null) {
      formDataMap['tdp_masa_berlaku'] = tdpMasaBerlaku;
    }

    // Text Fields
    if (permohonanSkrb != null) {
      formDataMap['permohonan_skrb'] = permohonanSkrb;
    }
    if (permohonanRekom != null) {
      formDataMap['permohonan_rekom'] = permohonanRekom;
    }
    if (alamatPermohonan != null) {
      formDataMap['alamat_permohonan'] = alamatPermohonan;
    }
    if (bidangUsaha != null) formDataMap['bidang_usaha'] = bidangUsaha;
    if (alamatLengkap != null) formDataMap['alamat_lengkap'] = alamatLengkap;

    final formData = FormData.fromMap(formDataMap);
    final response = await _dio.post(
      '/admin/customers/$customerId/document',
      data: formData,
    );
    return DocumentCustomer.fromJson(response.data);
  }

  /// DELETE: Hapus seluruh document customer (admin only)
  Future<void> deleteDocument(int customerId) async {
    await _dio.delete('/admin/customers/$customerId/document');
  }

  /// DELETE: Hapus satu file TDP berdasarkan index (admin only)
  Future<DocumentCustomer> deleteTdpFile(int customerId, int index) async {
    final response = await _dio.delete(
      '/admin/customers/$customerId/document/tdp/$index',
    );
    return DocumentCustomer.fromJson(response.data);
  }

  /// POST: Ganti satu file TDP berdasarkan index (admin only)
  Future<DocumentCustomer> replaceTdpFile(
    int customerId,
    int index,
    PlatformFile file,
  ) async {
    final formData = FormData.fromMap({
      'tdp_file': MultipartFile.fromBytes(file.bytes!, filename: file.name),
    });
    final response = await _dio.post(
      '/admin/customers/$customerId/document/tdp/$index/replace',
      data: formData,
    );
    return DocumentCustomer.fromJson(response.data);
  }

  /// GET: URL untuk preview PDF
  String getPdfViewUrl(int customerId, String type, {int? index}) {
    final baseUrl = _dio.options.baseUrl;
    if (type == 'tdp' && index != null) {
      return '$baseUrl/customers/$customerId/document/pdf/$type/$index';
    }
    return '$baseUrl/customers/$customerId/document/pdf/$type';
  }
}
