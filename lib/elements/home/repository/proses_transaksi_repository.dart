import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/app/core/providers.dart';

import '../../../data/providers/api_endpoints.dart';

// Provider untuk repository ini
final prosesTransaksiRepositoryProvider = Provider(
  (ref) => ProsesTransaksiRepository(ref),
);

class ProsesTransaksiRepository {
  final Ref _ref;
  ProsesTransaksiRepository(this._ref);

  Future<Uint8List> getPreviewPdf({
    required String transaksiId,
    required int pemeriksaId,
    required List<int> varianBodyIds,
    required List<int> judulGambarIds,
    required List<int>? hGambarOptionalIds, // <-- Terima List<int>?
    int? iGambarKelistrikanId,
  }) async {
    try {
      final response = await _ref
          .read(apiClientProvider)
          .dio
          .post(
            '${ApiEndpoints.transaksi}/$transaksiId/proses',
            data: {
              'pemeriksa_id': pemeriksaId,
              'varian_body_ids': varianBodyIds,
              'judul_gambar_ids': judulGambarIds,
              'h_gambar_optional_ids':
                  hGambarOptionalIds, // <-- Kirim dengan key yang benar
              'i_gambar_kelistrikan_id': iGambarKelistrikanId,
              'aksi': 'preview',
            },
            options: Options(responseType: ResponseType.bytes),
          );
      return response.data;
    } on DioException catch (e) {
      final errorData = e.response?.data;
      String message = e.message ?? 'Unknown error';
      if (errorData is List<int>) {
        try {
          message = String.fromCharCodes(errorData);
        } catch (_) {}
      }
      throw Exception('Gagal memuat preview: $message');
    }
  }

  Future<Map<String, dynamic>> prosesGambar({
    required String transaksiId,
    required int pemeriksaId,
    required List<int> varianBodyIds,
    required List<int> judulGambarIds,
    required List<int>? hGambarOptionalIds, // <-- Terima List<int>?
    int? iGambarKelistrikanId,
  }) async {
    try {
      final response = await _ref
          .read(apiClientProvider)
          .dio
          .post(
            '${ApiEndpoints.transaksi}/$transaksiId/proses',
            data: {
              'pemeriksa_id': pemeriksaId,
              'varian_body_ids': varianBodyIds,
              'judul_gambar_ids': judulGambarIds,
              'h_gambar_optional_ids':
                  hGambarOptionalIds, // <-- Kirim dengan key yang benar
              'i_gambar_kelistrikan_id': iGambarKelistrikanId,
              'aksi': 'proses',
            },
          );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        'Gagal memproses gambar: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }
}
