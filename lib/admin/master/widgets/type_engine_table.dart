import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Import package intl untuk format tanggal
import 'package:master_gambar/admin/master/models/type_engine.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:dio/dio.dart';
import '../repository/master_data_repository.dart';

class TypeEngineTable extends ConsumerWidget {
  const TypeEngineTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(typeEngineListProvider);
    final searchQuery = ref.watch(typeEngineSearchQueryProvider);

    return asyncData.when(
      data: (data) {
        // --- 2. Filter data berdasarkan pencarian ---
        final filteredData = data.where((item) {
          final query = searchQuery.toLowerCase();
          return item.name.toLowerCase().contains(query) ||
              item.id.toLowerCase().contains(query);
        }).toList();
        // -----------------------------------------

        return PaginatedDataTable2(
          columns: const [
            DataColumn2(label: Text('ID'), fixedWidth: 80),
            DataColumn2(label: Text('Type Engine'), size: ColumnSize.L),
            DataColumn2(label: Text('Dibuat Pada'), size: ColumnSize.M),
            DataColumn2(label: Text('Diupdate Pada'), size: ColumnSize.M),
            DataColumn2(label: Text('Options'), fixedWidth: 120),
          ],
          // --- 3. Gunakan data yang sudah difilter ---
          source: _TypeEngineDataSource(filteredData, context, ref),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}

class _TypeEngineDataSource extends DataTableSource {
  final List<TypeEngine> data;
  final BuildContext context;
  final WidgetRef ref;
  _TypeEngineDataSource(this.data, this.context, this.ref);

  @override
  DataRow? getRow(int index) {
    final item = data[index];
    // Buat formatter tanggal
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');

    return DataRow(
      cells: [
        DataCell(Text(item.id)),
        DataCell(Text(item.name)),
        // --- TAMBAHKAN CELL BARU ---
        DataCell(Text(dateFormat.format(item.createdAt.toLocal()))),
        DataCell(Text(dateFormat.format(item.updatedAt.toLocal()))),
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
  }

  void _showEditDialog(TypeEngine item) {
    final controller = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Type Engine: ${item.id}'),
        content: TextFormField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Nama Type Engine'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(masterDataRepositoryProvider)
                    .updateTypeEngine(id: item.id, typeEngine: controller.text);
                ref.invalidate(typeEngineListProvider);
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

  void _showDeleteDialog(TypeEngine item) {
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
                await ref
                    .read(masterDataRepositoryProvider)
                    .deleteTypeEngine(id: item.id);
                ref.invalidate(typeEngineListProvider);
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

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => data.length;
  @override
  int get selectedRowCount => 0;
}
