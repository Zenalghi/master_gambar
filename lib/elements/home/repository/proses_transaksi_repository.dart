//lib\elements\home\repository\proses_transaksi_repository.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/app/core/providers.dart';
import '../../../data/providers/api_endpoints.dart';
import '../providers/input_gambar_providers.dart';

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
    int? iGambarKelistrikanId,
  }) async {
    final kelistrikanId = _ref.read(selectedKelistrikanIdProvider);
    print("DEBUG SAVE: Kelistrikan ID yang akan dikirim: $kelistrikanId");
    try {
      await _ref
          .read(apiClientProvider)
          .dio
          .post(
            '${ApiEndpoints.transaksi}/$transaksiId/save',
            data: {
              'pemeriksa_id': pemeriksaId,
              'jumlah_gambar': jumlahGambar,
              'data_gambar_utama': dataGambarUtama,
              'ordered_independent_ids': orderedIndependentIds,
              'deskripsi_optional': deskripsiOptional,
              'i_gambar_kelistrikan_id': iGambarKelistrikanId,
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
    required List<int>? hGambarOptionalIds,
    required int pageNumber,
    String? deskripsiOptional,
    required List<int> orderedIndependentIds,
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
      throw Exception('Gagal memuat preview: ${e.message}');
    }
  }

  Future<void> downloadProcessedPdfsAsZip({
    required String transaksiId,
    required String suggestedFileName,
    required int pemeriksaId,
    required List<int> varianBodyIds,
    required List<int> judulGambarIds,
    required List<int>? hGambarOptionalIds,
    String? deskripsiOptional,
    List<int>? orderedIndependentIds,
    int? iGambarKelistrikanId,
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
              'judul_gambar_ids': judulGambarIds,
              'h_gambar_optional_ids': hGambarOptionalIds,
              'aksi': 'proses',
              'ordered_independent_ids': orderedIndependentIds,
              'deskripsi_optional': deskripsiOptional,
              'i_gambar_kelistrikan_id': iGambarKelistrikanId,
            },
            options: Options(responseType: ResponseType.bytes),
          )
          .then((response) async {
            await File(outputPath).writeAsBytes(response.data);
          });
    } on DioException catch (e) {
      throw Exception('Gagal memuat proses: ${e.message}');
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
