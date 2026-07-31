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

  Future<Skrb> createSkrb(String transaksiId) async {
    final response = await _dio.post(
      '/skrbs',
      data: {'transaksi_id': transaksiId},
    );
    if (response.data is! Map) {
      final cleanError = response.data.toString().replaceAll(RegExp(r"<[^>]*>"), "").trim();
      throw Exception('Server Error: $cleanError');
    }
    return Skrb.fromJson((response.data as Map)['data'] as Map<String, dynamic>);
  }

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
