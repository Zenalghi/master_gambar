import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/master_varian.dart';
import '../providers/master_data_providers.dart';
import '../repository/master_data_repository.dart';
import 'edit_master_varian_dialog.dart';

class MasterVarianDataSource extends AsyncDataTableSource {
  final WidgetRef _ref;
  final BuildContext context;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  MasterVarianDataSource(this._ref, this.context) {
    _ref.listen(masterVarianFilterProvider, (_, __) => refreshDatasource());
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final filters = _ref.read(masterVarianFilterProvider);

    try {
      final response = await _ref
          .read(masterDataRepositoryProvider)
          .getMasterVarianPaginated(
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
              DataCell(SelectableText(item.id.toString())),
              DataCell(SelectableText(item.jenisKendaraan?.name ?? '-')),
              DataCell(SelectableText(item.namaVarian)),
              DataCell(
                SelectableText(
                  item.createdAt != null
                      ? dateFormat.format(item.createdAt!.toLocal())
                      : '-',
                ),
              ),
              DataCell(
                SelectableText(
                  item.updatedAt != null
                      ? dateFormat.format(item.updatedAt!.toLocal())
                      : '-',
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.orange,
                        size: 16,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Edit',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) =>
                              EditMasterVarianDialog(masterVarian: item),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 16,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Hapus',
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
      debugPrint('Error fetching Master Varian: $e');
      return AsyncRowsResponse(0, []);
    }
  }

  void _showDeleteDialog(MasterVarian item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Anda yakin ingin menghapus "${item.namaVarian}"?'),
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
                    .deleteMasterVarian(id: item.id);
                refreshDatasource();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Data berhasil dihapus'),
                      backgroundColor: Colors.orange[400],
                    ),
                  );
                }
              } on DioException catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: ${e.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
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
