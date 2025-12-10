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

  Future<Uint8List> getPreviewPdf({
    required String transaksiId,
    required int pemeriksaId,
    required List<int> varianBodyIds,
    required List<int> judulGambarIds,
    required List<int>? hGambarOptionalIds,
    int? iGambarKelistrikanId,
    required int pageNumber,
    String? deskripsiOptional,
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
                  (hGambarOptionalIds != null && hGambarOptionalIds.isNotEmpty)
                  ? hGambarOptionalIds
                  : null, // <-- Kirim dengan key yang benar
              'i_gambar_kelistrikan_id': iGambarKelistrikanId,
              'aksi': 'preview',
              'preview_page': pageNumber,
              'deskripsi_optional': deskripsiOptional,
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

  Future<void> downloadProcessedPdfsAsZip({
    required String transaksiId,
    required String suggestedFileName, // Nama file zip yang disarankan
    required int pemeriksaId,
    required List<int> varianBodyIds,
    required List<int> judulGambarIds,
    required List<int>? hGambarOptionalIds,
    int? iGambarKelistrikanId,
    String? deskripsiOptional,
  }) async {
    try {
      // 1. Tampilkan dialog "Save As..." untuk mendapatkan path penyimpanan
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan file ZIP...',
        fileName: suggestedFileName,
        allowedExtensions: ['zip'],
        type: FileType.custom,
      );

      // Jika pengguna membatalkan dialog, hentikan proses
      if (outputPath == null) {
        throw Exception('Proses penyimpanan dibatalkan.');
      }

      // 2. Lakukan download dengan metode POST
      await _ref
          .read(apiClientProvider)
          .dio
          .post(
            '${ApiEndpoints.transaksi}/$transaksiId/proses',
            data: {
              'pemeriksa_id': pemeriksaId,
              'varian_body_ids': varianBodyIds,
              'judul_gambar_ids': judulGambarIds,
              'h_gambar_optional_ids':
                  (hGambarOptionalIds != null && hGambarOptionalIds.isNotEmpty)
                  ? hGambarOptionalIds
                  : null,
              'i_gambar_kelistrikan_id': iGambarKelistrikanId,
              'aksi': 'proses',
              'deskripsi_optional': deskripsiOptional,
            },
            options: Options(
              responseType:
                  ResponseType.bytes, // Terima data sebagai byte mentah
            ),
            // Simpan file langsung ke path yang dipilih pengguna
            onReceiveProgress: (received, total) {
              // Di sini Anda bisa menambahkan logika untuk menampilkan progress bar jika mau
            },
          )
          .then((response) async {
            // Tulis byte yang diterima ke dalam file
            await File(outputPath).writeAsBytes(response.data);
          });
    } on DioException catch (e) {
      throw Exception(
        'Gagal mengunduh file: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }

  // Helper: Ambil Info Kelistrikan berdasarkan Master Data ID
  Future<Map<String, dynamic>?> getKelistrikanByMasterData(
    int masterDataId,
  ) async {
    try {
      // Kita panggil endpoint Master Data Detail (atau list dengan filter)
      // Asumsi: endpoint master-data/{id} sudah mengembalikan kolom kelistrikan_id & deskripsi
      // Jika belum ada endpoint detail, kita pakai list dengan filter ID
      final response = await _ref
          .read(apiClientProvider)
          .dio
          .get(
            '/admin/master-data',
            queryParameters: {
              'search': masterDataId.toString(),
              'perPage': 1,
            }, // Search by ID spesifik
          );

      final List data = response.data['data'];
      if (data.isNotEmpty) {
        final item = data.first;
        // Pastikan ID-nya cocok (karena search bisa fuzzy)
        if (item['id'] == masterDataId) {
          return {
            'id': item['kelistrikan_id'],
            'deskripsi': item['kelistrikan_deskripsi'],
            'file_id': item['file_kelistrikan_id'],
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
