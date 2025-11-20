// File: lib/admin/master/widgets/varian_body_datasource.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/master/models/varian_body.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
// Pastikan Anda punya dialog edit (jika belum, bisa dibuat nanti)
// import 'edit_varian_body_dialog.dart';

class VarianBodyDataSource extends AsyncDataTableSource {
  final WidgetRef _ref;
  final BuildContext context;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  VarianBodyDataSource(this._ref, this.context) {
    _ref.listen(varianBodyFilterProvider, (_, __) => refreshDatasource());
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final filters = _ref.read(varianBodyFilterProvider);
    try {
      final response = await _ref
          .read(masterDataRepositoryProvider)
          .getVarianBodyListPaginated(
            perPage: count,
            page: (startIndex ~/ count) + 1,
            search: filters['search']!,
            sortBy: filters['sortBy']!,
            sortDirection: filters['sortDirection']!,
          );

      return AsyncRowsResponse(
        response.total,
        response.data.map((item) {
          // Akses data induk melalui masterData
          final md = item.masterData;

          return DataRow(
            key: ValueKey(item.id),
            cells: [
              DataCell(SelectableText(md.typeEngine.name)),
              DataCell(SelectableText(md.merk.name)),
              DataCell(SelectableText(md.typeChassis.name)),
              DataCell(SelectableText(md.jenisKendaraan.name)),
              DataCell(SelectableText(item.name)), // Nama Varian Body
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
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // _showEditDialog(item); // Uncomment jika dialog edit sudah ada
                      },
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
      debugPrint('Error fetching Varian Body: $e');
      return AsyncRowsResponse(0, []);
    }
  }

  void _showDeleteDialog(VarianBody item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Anda yakin ingin menghapus "${item.name}"?'),
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
                    .deleteVarianBody(id: item.id);
                refreshDatasource(); // Refresh tabel setelah hapus
                if (context.mounted) Navigator.of(context).pop();
              } catch (e) {
                // Error handling global biasanya sudah ada di repository atau dio interceptor
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal menghapus data'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
