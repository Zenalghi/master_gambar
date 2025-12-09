// File: lib/admin/master/widgets/gambar_kelistrikan_datasource.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/master/models/master_kelistrikan_file.dart'; // Model Baru
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'pdf_viewer_dialog.dart'; // Pastikan file ini ada

class GambarKelistrikanDataSource extends AsyncDataTableSource {
  final WidgetRef _ref;
  final BuildContext context;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  GambarKelistrikanDataSource(this._ref, this.context) {
    // Dengarkan perubahan filter untuk refresh otomatis
    _ref.listen(
      gambarKelistrikanFilterProvider,
      (_, __) => refreshDatasource(),
    );
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final filters = _ref.read(gambarKelistrikanFilterProvider);
    try {
      // Panggil endpoint untuk mengambil list FILE fisik
      final response = await _ref
          .read(masterDataRepositoryProvider)
          .getKelistrikanFilesPaginated(
            perPage: count,
            page: (startIndex ~/ count) + 1,
            search: filters['search']!,
            sortBy: filters['sortBy']!,
            sortDirection: filters['sortDirection']!,
          );

      return AsyncRowsResponse(
        response.total,
        response.data.map((item) {
          // Akses data hirarki dari nested object typeChassis
          // Pastikan model TypeChassis Anda memiliki relasi 'merk' dan 'typeEngine' yang sudah ter-parsing
          final tc = item.typeChassis;
          final merk = tc.merk;
          final engine = merk?.typeEngine;

          return DataRow(
            key: ValueKey(item.id),
            cells: [
              // 1. ID File
              DataCell(SelectableText(item.id.toString())),

              // 2. Info Kendaraan (Hierarki)
              DataCell(SelectableText(engine!.name)), // Type Engine
              DataCell(SelectableText(merk!.name)), // Merk
              DataCell(SelectableText(tc.name)), // Type Chassis
              // 3. Tanggal
              DataCell(
                SelectableText(dateFormat.format(item.createdAt.toLocal())),
              ),
              DataCell(
                SelectableText(dateFormat.format(item.updatedAt.toLocal())),
              ),

              // 4. Options (View & Delete)
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tombol Lihat PDF
                    IconButton(
                      icon: Icon(Icons.visibility, color: Colors.blue.shade700),
                      tooltip: 'Lihat PDF',
                      onPressed: () => _showPdfPreview(item),
                    ),
                    // Tombol Hapus File
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Hapus File',
                      onPressed: () => _showDeleteDialog(item),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      );
    } catch (e) {
      debugPrint('Error fetching Kelistrikan Files: $e');
      return AsyncRowsResponse(0, []);
    }
  }

  // --- LOGIKA PREVIEW PDF ---
  void _showPdfPreview(MasterKelistrikanFile item) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Kita gunakan path file dari item untuk mengambil PDF
      final pdfData = await _ref
          .read(masterDataRepositoryProvider)
          .getPdfFromPath(item.pathFile);

      if (context.mounted) Navigator.of(context).pop(); // Tutup loading

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => PdfViewerDialog(
            pdfData: pdfData,
            title: 'Kelistrikan - ${item.typeChassis.name}',
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop(); // Tutup loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- LOGIKA HAPUS FILE ---
  void _showDeleteDialog(MasterKelistrikanFile item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus File Kelistrikan?'),
        content: Text(
          'PERINGATAN: File fisik untuk chassis "${item.typeChassis.name}" akan dihapus permanen.\n\n'
          'Semua Master Data yang menggunakan file ini akan kehilangan referensi ke gambar kelistrikannya.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              try {
                // Panggil repository untuk hapus file fisik
                await _ref
                    .read(masterDataRepositoryProvider)
                    .deleteKelistrikanFile(id: item.id);

                refreshDatasource(); // Refresh tabel

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('File berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Hapus Permanen'),
          ),
        ],
      ),
    );
  }
}
