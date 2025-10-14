import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/master/models/type_chassis.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';

class TypeChassisDataSource extends AsyncDataTableSource {
  final WidgetRef _ref;
  final BuildContext context;

  TypeChassisDataSource(this._ref, this.context) {
    _ref.listen(typeChassisFilterProvider, (_, __) => refreshDatasource());
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final filters = _ref.read(typeChassisFilterProvider);
    try {
      final response = await _ref
          .read(masterDataRepositoryProvider)
          .getTypeChassisPaginated(
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
              DataCell(SelectableText(item.id)),
              DataCell(SelectableText(item.name)),
              DataCell(SelectableText('${item.merk.name} (${item.merk.id})')),
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
      debugPrint('Error fetching Type Chassis: $e');
      return AsyncRowsResponse(0, []);
    }
  }

  void _showEditDialog(TypeChassis item) {
    final controller = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Type Chassis: ${item.id}'),
        content: TextFormField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Nama Type Chassis'),
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
                    .updateTypeChassis(
                      id: item.id,
                      typeChassis: controller.text,
                    );
                refreshDatasource();
                Navigator.of(context).pop();
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
      ),
    );
  }

  void _showDeleteDialog(TypeChassis item) {
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
                    .deleteTypeChassis(id: item.id);
                refreshDatasource();
                Navigator.of(context).pop();
              } on DioException catch (e) {
                final errorMessages = e.response?.data['errors'];
                final message = errorMessages != null
                    ? errorMessages['general'][0]
                    : 'Terjadi kesalahan.';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
