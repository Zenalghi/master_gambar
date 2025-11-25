// File: lib/admin/master/widgets/gambar_optional_datasource.dart

import 'package:data_table_2/data_table_2.dart';
// import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/master/models/gambar_optional.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'edit_gambar_optional_dialog.dart';
import 'pdf_viewer_dialog.dart'; // Pastikan file ini sudah ada

class GambarOptionalDataSource extends AsyncDataTableSource {
  final WidgetRef _ref;
  final BuildContext context;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd\nHH:mm');

  GambarOptionalDataSource(this._ref, this.context) {
    _ref.listen(gambarOptionalFilterProvider, (_, __) => refreshDatasource());
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final filters = _ref.read(gambarOptionalFilterProvider);
    try {
      final response = await _ref
          .read(masterDataRepositoryProvider)
          .getGambarOptionalListPaginated(
            perPage: count,
            page: (startIndex ~/ count) + 1,
            search: filters['search'] as String,
            sortBy: filters['sortBy'] as String,
            sortDirection: filters['sortDirection'] as String,
          );

      return AsyncRowsResponse(
        response.total,
        response.data.map((item) {
          // Akses hirarki data melalui varianBody -> masterData
          final vb = item.varianBody;
          final md = vb?.masterData;

          return DataRow(
            // key: ValueKey(item.id),
            cells: [
              DataCell(SelectableText(item.id.toString())),
              DataCell(SelectableText(md?.typeEngine.name ?? '')),
              DataCell(SelectableText(md?.merk.name ?? '')),
              DataCell(SelectableText(md?.typeChassis.name ?? '')),
              DataCell(SelectableText(md?.jenisKendaraan.name ?? '')),
              DataCell(SelectableText(vb?.name ?? '')),

              // Kolom Tipe
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: item.tipe == 'paket'
                        ? Colors.blue.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.tipe.toUpperCase(),
                    style: TextStyle(
                      color: item.tipe == 'paket'
                          ? Colors.blue.shade800
                          : Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),

              DataCell(SelectableText(item.deskripsi)),
              DataCell(
                SelectableText(dateFormat.format(item.createdAt.toLocal())),
              ),
              DataCell(
                SelectableText(dateFormat.format(item.updatedAt.toLocal())),
              ),

              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tombol View PDF
                    IconButton(
                      icon: Icon(Icons.visibility, color: Colors.blue.shade700),
                      tooltip: 'Lihat PDF',
                      onPressed: () => _showPdfPreview(item),
                    ),
                    // Tombol Edit
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) =>
                            EditGambarOptionalDialog(gambarOptional: item),
                      ),
                    ),
                    // Tombol Delete (Anda bisa tambahkan _showDeleteDialog jika perlu)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
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
      debugPrint('Error fetching Gambar Optional: $e');
      return AsyncRowsResponse(0, []);
    }
  }

  void _showPdfPreview(GambarOptional item) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final pdfData = await _ref
          .read(masterDataRepositoryProvider)
          .getGambarOptionalPdf(item.id);

      if (context.mounted) Navigator.of(context).pop(); // Tutup loading

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) =>
              PdfViewerDialog(pdfData: pdfData, title: item.deskripsi),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop(); // Tutup loading

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(GambarOptional item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Anda yakin ingin menghapus gambar "${item.deskripsi}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              try {
                await _ref
                    .read(masterDataRepositoryProvider)
                    .deleteGambarOptional(id: item.id);
                refreshDatasource();
                if (context.mounted) Navigator.of(context).pop();
              } catch (e) {
                // Handle error
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
