// File: lib/admin/master/widgets/gambar_kelistrikan_datasource.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
// Import dialog edit yang akan kita buat
import '../models/gambar_kelistrikan.dart';
import 'edit_gambar_kelistrikan_dialog.dart';

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
          final tc = item.typeChassis;
          return DataRow(
            key: ValueKey(item.id),
            cells: [
              DataCell(SelectableText(tc.merk.typeEngine.name)),
              DataCell(SelectableText(tc.merk.name)),
              DataCell(SelectableText('${tc.name} (${tc.id})')),
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
                      icon: const Icon(Icons.edit),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => EditGambarKelistrikanDialog(
                          gambarKelistrikan: item,
                        ),
                      ),
                    ),
                    // ... tombol delete
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
      debugPrint('Error fetching Gambar Kelistrikan: $e');
      return AsyncRowsResponse(0, []);
    }
  }

  void _showDeleteConfirmation(GambarKelistrikan item) {
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
          .deleteGambarKelistrikan(id: id);
      _ref.invalidate(gambarKelistrikanFilterProvider);
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
}
