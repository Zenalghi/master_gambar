// File: lib/elements/home/repository/skrb_repository.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/app/core/providers.dart';
import 'package:master_gambar/data/models/skrb.dart';

final skrbRepositoryProvider = Provider((ref) => SkrbRepository(ref));

class SkrbRepository {
  final Ref _ref;
  SkrbRepository(this._ref);

  Dio get _dio => _ref.read(apiClientProvider).dio;

  Future<List<Skrb>> getSkrbList() async {
    final response = await _dio.get('/skrbs');
    final data = response.data['data'] as List;
    return data.map((e) => Skrb.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<SkrbAvailableTransaction>> getAvailableTransactions() async {
    final response = await _dio.get('/skrbs/available-transactions');
    final data = response.data['data'] as List;
    return data
        .map((e) => SkrbAvailableTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Cara 1: Buat SKRB dari ID Transaksi.
  /// Jika sudah ada SKRB untuk transaksi ini → response alreadyExists = true.
  Future<Skrb> createSkrbViaCara1(
    String transaksiId, {
    int? nomorUrutManual,
  }) async {
    final payload = <String, dynamic>{'transaksi_id': transaksiId};
    if (nomorUrutManual != null) {
      payload['nomor_urut_manual'] = nomorUrutManual;
    }
    final response = await _dio.post('/skrbs', data: payload);
    if (response.data is! Map) {
      final cleanError = response.data.toString().replaceAll(RegExp(r"<[^>]*>"), "").trim();
      throw Exception('Server Error: $cleanError');
    }
    return Skrb.fromJson((response.data as Map)['data'] as Map<String, dynamic>);
  }

  /// Cara 2: Buat SKRB tanpa transaksi — dari customer + kendaraan + jenis pengajuan.
  Future<Skrb> createSkrbViaCara2({
    required int customerId,
    required int masterDataId,
    required int jenisPengajuanId,
    int? nomorUrutManual,
  }) async {
    final payload = <String, dynamic>{
      'customer_id': customerId,
      'master_data_id': masterDataId,
      'jenis_pengajuan_id': jenisPengajuanId,
    };
    if (nomorUrutManual != null) {
      payload['nomor_urut_manual'] = nomorUrutManual;
    }
    final response = await _dio.post('/skrbs', data: payload);
    if (response.data is! Map) {
      final cleanError = response.data.toString().replaceAll(RegExp(r"<[^>]*>"), "").trim();
      throw Exception('Server Error: $cleanError');
    }
    return Skrb.fromJson((response.data as Map)['data'] as Map<String, dynamic>);
  }

  /// Preview ID SKRB sistem berikutnya untuk customer tertentu (sebelum membuat).
  Future<Map<String, dynamic>> getPreviewIdSkrb(int customerId) async {
    final response = await _dio.get(
      '/skrbs/preview-id',
      queryParameters: {'customer_id': customerId},
    );
    if (response.data is! Map) throw Exception('Respons tidak valid dari server.');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// Update data inti SKRB (customer, kendaraan, jenis pengajuan) untuk Edit SKRB dialog.
  Future<void> updateSkrbData(
    int skrbId, {
    int? customerId,
    int? masterDataId,
    int? jenisPengajuanId,
  }) async {
    final payload = <String, dynamic>{};
    if (customerId != null) payload['customer_id'] = customerId;
    if (masterDataId != null) payload['master_data_id'] = masterDataId;
    if (jenisPengajuanId != null) payload['jenis_pengajuan_id'] = jenisPengajuanId;
    await _dio.put('/skrbs/$skrbId', data: payload);
  }

  /// Legacy alias — tetap tersedia untuk backward-compat.
  @Deprecated('Gunakan createSkrbViaCara1')
  Future<Skrb> createSkrb(String transaksiId) => createSkrbViaCara1(transaksiId);

  Future<Skrb> getSkrbDetail(int skrbId) async {
    final response = await _dio.get('/skrbs/$skrbId');
    if (response.data is! Map) {
      final cleanError = response.data.toString().replaceAll(RegExp(r"<[^>]*>"), "").trim();
      throw Exception('Server Error: $cleanError');
    }
    return Skrb.fromJson((response.data as Map)['data'] as Map<String, dynamic>);
  }

  Future<Skrb> generateGambarUtamaBackground(int skrbId) async {
    final response = await _dio.post('/skrbs/$skrbId/generate-gambar');
    if (response.data is! Map) {
      final cleanError = response.data.toString().replaceAll(RegExp(r"<[^>]*>"), "").trim();
      throw Exception('Server Error: $cleanError');
    }
    return Skrb.fromJson((response.data as Map)['data'] as Map<String, dynamic>);
  }

  Future<void> updatePhase(int skrbId, int newFase) async {
    await _dio.put('/skrbs/$skrbId', data: {'fase': newFase});
  }

  Future<void> updateHiddenFlags(
    int skrbId,
    Map<String, dynamic> hiddenFlags,
  ) async {
    await _dio.put('/skrbs/$skrbId', data: {'hidden_flags': hiddenFlags});
  }

  Future<void> updateGambarUtamaList(
    int skrbId,
    List<Map<String, dynamic>> gambarUtamaList,
  ) async {
    await _dio.put('/skrbs/$skrbId', data: {'gambar_utama_list': gambarUtamaList});
  }

  Future<void> updateFotoCopySkrb(int skrbId, String? fotoCopySkrb) async {
    await _dio.put('/skrbs/$skrbId', data: {'foto_copy_skrb': fotoCopySkrb ?? ''});
  }

  Future<void> updateTanggalPermohonan(int skrbId, String? tanggalPermohonan) async {
    await _dio.put('/skrbs/$skrbId', data: {'tanggal_permohonan': tanggalPermohonan ?? ''});
  }

  Future<void> uploadFile(int skrbId, String key, PlatformFile file) async {
    if (file.bytes == null) throw Exception('Data file PDF tidak valid.');

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(file.bytes!, filename: file.name),
    });

    await _dio.post('/skrbs/$skrbId/upload/$key', data: formData);
  }

  Future<void> resetFiles(int skrbId) async {
    await _dio.post('/skrbs/$skrbId/reset-files');
  }

  Future<void> deleteSkrb(int skrbId) async {
    await _dio.delete('/skrbs/$skrbId');
  }

  Future<void> mergeSkrb(
    int skrbId, {
    bool download = false,
    String? suggestedFileName,
  }) async {
    if (download) {
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan file SKRB...',
        fileName: suggestedFileName ?? 'PERMOHONAN_SKRB.pdf',
        allowedExtensions: ['pdf'],
        type: FileType.custom,
      );

      if (outputPath == null) {
        throw Exception('Proses pengunduhan dibatalkan oleh pengguna.');
      }

      final response = await _dio.post(
        '/skrbs/$skrbId/merge',
        queryParameters: {'download': 'true'},
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      await File(outputPath).writeAsBytes(response.data);
    } else {
      await _dio.post(
        '/skrbs/$skrbId/merge',
        queryParameters: {'download': 'false'},
      );
    }
  }

  Future<void> downloadHistory(int historyId, String fileName) async {
    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Unduh arsip SKRB...',
      fileName: fileName,
      allowedExtensions: ['pdf'],
      type: FileType.custom,
    );

    if (outputPath == null) {
      throw Exception('Proses pengunduhan dibatalkan.');
    }

    final response = await _dio.get(
      '/skrb-histories/$historyId/download',
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(minutes: 5),
      ),
    );

    await File(outputPath).writeAsBytes(response.data);
  }

  Future<void> deleteHistory(int historyId) async {
    await _dio.delete('/skrb-histories/$historyId');
  }

  Future<void> deleteAllHistories(int skrbId) async {
    await _dio.delete('/skrbs/$skrbId/histories');
  }

  String getPdfViewUrl(int skrbId, String key, {int? index}) {
    final baseUrl = _dio.options.baseUrl;
    if (key == '3' && index != null) {
      return '$baseUrl/skrbs/$skrbId/preview/$key?index=$index';
    }
    return '$baseUrl/skrbs/$skrbId/preview/$key';
  }

  String getHistoryViewUrl(int historyId) {
    final baseUrl = _dio.options.baseUrl;
    return '$baseUrl/skrb-histories/$historyId/view';
  }

  Future<Uint8List> getPdfBytes(String url) async {
    final response = await _dio.get<Uint8List>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(minutes: 2),
      ),
    );
    if (response.data == null) {
      throw Exception('Data file PDF tidak ditemukan di server.');
    }
    return response.data!;
  }

  Future<Map<String, dynamic>> getSkrbStorageInfo(int skrbId) async {
    final response = await _dio.get('/skrbs/$skrbId/storage-info');
    return response.data as Map<String, dynamic>;
  }
}
