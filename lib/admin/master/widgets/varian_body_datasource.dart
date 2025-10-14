// File: lib/admin/master/widgets/varian_body_datasource.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/master/models/varian_body.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';

class VarianBodyDataSource extends AsyncDataTableSource {
  final WidgetRef _ref;
  final BuildContext context;

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
          final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
          return DataRow(
            key: ValueKey(item.id),
            cells: [
              DataCell(SelectableText(item.id.toString())),
              DataCell(SelectableText(item.name)),
              DataCell(
                SelectableText(
                  '${item.jenisKendaraan.name} (${item.jenisKendaraan.id})',
                ),
              ),
              //typechassis
              DataCell(
                SelectableText(
                  '${item.jenisKendaraan.typeChassis.name} (${item.jenisKendaraan.typeChassis.id})',
                ),
              ),
              DataCell(
                SelectableText(
                  '${item.jenisKendaraan.typeChassis.merk.name} (${item.jenisKendaraan.typeChassis.merk.id})',
                ),
              ),
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
                      onPressed: () => _showEditDialog(item),
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

  void _showEditDialog(VarianBody item) {
    final controller = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Varian Body'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Nama Varian Body'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _ref
                      .read(masterDataRepositoryProvider)
                      .updateVarianBody(
                        id: item.id,
                        varianBody: controller.text,
                        jenisKendaraanId: item.jenisKendaraan.id,
                      );
                  Navigator.of(context).pop();
                  refreshDatasource();
                } on DioException catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.response?.data['message']}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(VarianBody item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus Varian Body '
            '"${item.name}" (ID: ${item.id})?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _ref
                      .read(masterDataRepositoryProvider)
                      .deleteVarianBody(id: item.id);
                  Navigator.of(context).pop();
                  refreshDatasource();
                } on DioException catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.response?.data['message']}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
