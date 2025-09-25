import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/app/core/providers.dart';

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
    required List<String> judulGambar, // <-- Tambah
    int? hGambarOptionalId,
    int? iGambarKelistrikanId,
  }) async {
    try {
      final response = await _ref
          .read(apiClientProvider)
          .dio
          .post(
            '/transaksi/$transaksiId/proses',
            data: {
              'pemeriksa_id': pemeriksaId,
              'varian_body_ids': varianBodyIds,
              'judul_gambar': judulGambar,
              'h_gambar_optional_id': hGambarOptionalId,
              'i_gambar_kelistrikan_id': iGambarKelistrikanId,
              'aksi': 'preview', // Kirim aksi 'preview'
            },
            // Minta Dio untuk menerima respons sebagai byte mentah
            options: Options(responseType: ResponseType.bytes),
          );
      // Kembalikan data PDF sebagai Uint8List
      return response.data;
    } on DioException catch (e) {
      // Jika ada error dari server, coba ekstrak pesannya
      final errorData = e.response?.data;
      String message = e.message ?? 'Unknown error';
      if (errorData is List<int>) {
        // Coba decode error JSON jika responsnya byte
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
    required List<String> judulGambar, // <-- Tambah
    int? hGambarOptionalId,
    int? iGambarKelistrikanId,
  }) async {
    try {
      final response = await _ref
          .read(apiClientProvider)
          .dio
          .post(
            '/transaksi/$transaksiId/proses',
            data: {
              'pemeriksa_id': pemeriksaId,
              'varian_body_ids': varianBodyIds,
              'judul_gambar': judulGambar,
              'h_gambar_optional_id': hGambarOptionalId,
              'i_gambar_kelistrikan_id': iGambarKelistrikanId,
              'aksi': 'proses', // Kirim aksi 'proses'
            },
            // Untuk 'proses', kita harapkan respons JSON, bukan byte
            // Jadi tidak perlu options ResponseType.bytes
          );
      // Kembalikan data JSON sebagai Map
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Tangani error dari server
      throw Exception(
        'Gagal memproses gambar: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }
}
