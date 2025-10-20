import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/master/models/gambar_optional.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'edit_gambar_optional_dialog.dart';
import 'pdf_viewer_dialog.dart';

class GambarOptionalDataSource extends AsyncDataTableSource {
  final WidgetRef _ref;
  final BuildContext context;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

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
            search: filters['search']!,
            sortBy: filters['sortBy']!,
            sortDirection: filters['sortDirection']!,
          );

      return AsyncRowsResponse(
        response.total,
        response.data.map((item) {
          final vb = item.varianBody;
          return DataRow(
            key: ValueKey(item.id),
            cells: [
              DataCell(
                SelectableText(
                  vb?.jenisKendaraan.typeChassis.merk.typeEngine.name ?? 'N/A',
                ),
              ),
              DataCell(
                SelectableText(
                  vb?.jenisKendaraan.typeChassis.merk.name ?? 'N/A',
                ),
              ),
              DataCell(
                SelectableText(vb?.jenisKendaraan.typeChassis.name ?? 'N/A'),
              ),
              DataCell(
                SelectableText(
                  '${vb?.jenisKendaraan.name ?? 'N/A'} (${vb?.jenisKendaraan.id ?? ''})',
                ),
              ),
              DataCell(
                SelectableText('${vb?.name ?? 'N/A'} (${vb?.id ?? ''})'),
              ),
              DataCell(SelectableText(item.tipe)),
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
                        builder: (_) =>
                            EditGambarOptionalDialog(gambarOptional: item),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red.shade700),
                      tooltip: 'Hapus',
                      onPressed: () => _showDeleteConfirmation(item),
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

  void _showDeleteConfirmation(GambarOptional item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Anda yakin ingin menghapus "${item.deskripsi}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ya, Hapus'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteItem(item.id);
            },
          ),
        ],
      ),
    );
  }

  void _deleteItem(int id) async {
    try {
      await _ref
          .read(masterDataRepositoryProvider)
          .deleteGambarOptional(id: id);
      _ref.invalidate(gambarOptionalFilterProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.response?.data['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPdfPreview(GambarOptional item) async {
    // Tampilkan loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Panggil repository untuk mengambil data PDF
      final pdfData = await _ref
          .read(masterDataRepositoryProvider)
          .getGambarOptionalPdf(item.id);

      Navigator.of(context).pop(); // Tutup dialog loading

      if (!context.mounted) return;

      // Tampilkan dialog PDF viewer
      showDialog(
        context: context,
        builder: (context) =>
            PdfViewerDialog(pdfData: pdfData, title: item.deskripsi),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Tutup dialog loading jika error

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
