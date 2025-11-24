// File: lib/admin/master/widgets/gambar_kelistrikan_datasource.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/master/models/gambar_kelistrikan.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'edit_gambar_kelistrikan_dialog.dart';
import 'pdf_viewer_dialog.dart';

class GambarKelistrikanDataSource extends AsyncDataTableSource {
  final WidgetRef _ref;
  final BuildContext context;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  GambarKelistrikanDataSource(this._ref, this.context) {
    _ref.listen(
      gambarKelistrikanFilterProvider,
      (_, __) => refreshDatasource(),
    );
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final filters = _ref.read(gambarKelistrikanFilterProvider);
    try {
      final response = await _ref
          .read(masterDataRepositoryProvider)
          .getGambarKelistrikanListPaginated(
            perPage: count,
            page: (startIndex ~/ count) + 1,
            search: filters['search']!,
            sortBy: filters['sortBy']!,
            sortDirection: filters['sortDirection']!,
          );

      return AsyncRowsResponse(
        response.total,
        response.data.map((item) {
          return DataRow(
            key: ValueKey(item.id),
            cells: [
              // Akses langsung dari properti model yang baru
              DataCell(SelectableText(item.typeEngine.name)),
              DataCell(SelectableText(item.merk.name)),
              DataCell(SelectableText(item.typeChassis.name)),
              DataCell(SelectableText(item.deskripsi)),
              DataCell(
                SelectableText(dateFormat.format(item.createdAt.toLocal())),
              ),
              DataCell(
                SelectableText(dateFormat.format(item.updatedAt.toLocal())),
              ),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.visibility, color: Colors.blue.shade700),
                      tooltip: 'Lihat PDF',
                      onPressed: () => _showPdfPreview(item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => EditGambarKelistrikanDialog(
                          gambarKelistrikan: item,
                        ),
                      ),
                    ),
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
      debugPrint('Error fetching Gambar Kelistrikan: $e');
      return AsyncRowsResponse(0, []);
    }
  }

  void _showPdfPreview(GambarKelistrikan item) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final pdfData = await _ref
          .read(masterDataRepositoryProvider)
          .getGambarKelistrikanPdf(item.id);

      if (context.mounted) Navigator.of(context).pop();

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) =>
              PdfViewerDialog(pdfData: pdfData, title: item.deskripsi),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();

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

  void _showDeleteDialog(GambarKelistrikan item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Anda yakin ingin menghapus "${item.deskripsi}"?'),
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
                    .deleteGambarKelistrikan(id: item.id);
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
