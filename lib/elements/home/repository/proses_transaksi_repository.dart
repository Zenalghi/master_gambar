//lib\elements\home\repository\proses_transaksi_repository.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/app/core/providers.dart';
import '../../../data/providers/api_endpoints.dart';

final prosesTransaksiRepositoryProvider = Provider(
  (ref) => ProsesTransaksiRepository(ref),
);

class ProsesTransaksiRepository {
  final Ref _ref;
  ProsesTransaksiRepository(this._ref);

  Future<void> saveDraft({
    required String transaksiId,
    required int? pemeriksaId,
    required int jumlahGambar,
    required List<Map<String, dynamic>> dataGambarUtama,
    List<int>? orderedIndependentIds,
    String? deskripsiOptional,
  }) async {
    try {
      await _ref
          .read(apiClientProvider)
          .dio
          .post(
            '${ApiEndpoints.transaksi}/$transaksiId/save',
            data: {
              'pemeriksa_id': pemeriksaId,
              'jumlah_gambar': jumlahGambar,
              'data_gambar_utama':
                  dataGambarUtama, // Kirim array object [{judul_id:1, varian_id:2}]
              'ordered_independent_ids': orderedIndependentIds,
              'deskripsi_optional': deskripsiOptional,
            },
          );
    } on DioException catch (e) {
      throw Exception(
        'Gagal menyimpan draft: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }

  Future<Uint8List> getPreviewPdf({
    required String transaksiId,
    required int pemeriksaId,
    required List<int> varianBodyIds,
    required List<int> judulGambarIds,
    required List<int>? hGambarOptionalIds, // Tambahkan ini (Untuk Paket)
    int? iGambarKelistrikanId,
    required int pageNumber,
    String? deskripsiOptional,
    required List<int> orderedIndependentIds,
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

              // --- PERBAIKAN 1: Pastikan key ini ada ---
              'judul_gambar_ids': judulGambarIds,

              // --- PERBAIKAN 2: Kirim ID Paket (Dependent) ---
              'h_gambar_optional_ids': hGambarOptionalIds,

              'i_gambar_kelistrikan_id': iGambarKelistrikanId,
              'aksi': 'preview',
              'preview_page': pageNumber,
              'deskripsi_optional': deskripsiOptional,
              'ordered_independent_ids': orderedIndependentIds,
            },
            options: Options(responseType: ResponseType.bytes),
          );
      return response.data;
    } on DioException catch (e) {
      // ... error handling sama ...
      throw Exception('Gagal memuat preview: ${e.message}');
    }
  }

  Future<void> downloadProcessedPdfsAsZip({
    required String transaksiId,
    required String suggestedFileName,
    required int pemeriksaId,
    required List<int> varianBodyIds,
    required List<int> judulGambarIds,
    required List<int>? hGambarOptionalIds, // Tambahkan ini
    int? iGambarKelistrikanId,
    String? deskripsiOptional,
    List<int>? orderedIndependentIds,
  }) async {
    try {
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan file ZIP...',
        fileName: suggestedFileName,
        allowedExtensions: ['zip'],
        type: FileType.custom,
      );

      if (outputPath == null) throw Exception('Proses penyimpanan dibatalkan.');

      await _ref
          .read(apiClientProvider)
          .dio
          .post(
            '${ApiEndpoints.transaksi}/$transaksiId/proses',
            data: {
              'pemeriksa_id': pemeriksaId,
              'varian_body_ids': varianBodyIds,

              // --- PERBAIKAN 1: Pastikan key ini ada ---
              'judul_gambar_ids': judulGambarIds,

              // --- PERBAIKAN 2: Kirim ID Paket ---
              'h_gambar_optional_ids': hGambarOptionalIds,

              'i_gambar_kelistrikan_id': iGambarKelistrikanId,
              'aksi': 'proses',
              'ordered_independent_ids': orderedIndependentIds,
              'deskripsi_optional': deskripsiOptional,
            },
            options: Options(responseType: ResponseType.bytes),
          )
          .then((response) async {
            await File(outputPath).writeAsBytes(response.data);
          });
    } on DioException catch (e) {
      // ... error handling ...
      throw Exception(e.message);
    }
  }

  // Helper: Ambil Info Kelistrikan berdasarkan Master Data ID
  Future<Map<String, dynamic>?> getKelistrikanByMasterData(
    int masterDataId,
  ) async {
    try {
      // Panggil API baru yang sudah Anda buat di Laravel
      final response = await _ref
          .read(apiClientProvider)
          .dio
          .get('/options/kelistrikan-status/$masterDataId');

      // Response backend: {status_code, display_text, file_id, desc_id}
      // Kita kembalikan mentah-mentah karena formatnya sudah pas
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteTransaksi(String transaksiId) async {
    try {
      await _ref
          .read(apiClientProvider)
          .dio
          .delete('${ApiEndpoints.transaksi}/$transaksiId');
    } on DioException catch (e) {
      throw Exception(
        'Gagal menghapus transaksi: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }
}
