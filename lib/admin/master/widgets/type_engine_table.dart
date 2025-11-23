// File: lib/admin/master/widgets/type_engine_table.dart

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/type_engine.dart';
import '../providers/master_data_providers.dart';
import '../repository/master_data_repository.dart';

class TypeEngineTable extends ConsumerStatefulWidget {
  const TypeEngineTable({super.key});

  @override
  ConsumerState<TypeEngineTable> createState() => _TypeEngineTableState();
}

class _TypeEngineTableState extends ConsumerState<TypeEngineTable> {
  int _sortColumnIndex = 0; // Default sort: ID
  bool _sortAscending = true; // Default: A-Z (asc)

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(typeEngineListProvider);
    final searchQuery = ref.watch(typeEngineSearchQueryProvider);

    return asyncData.when(
      data: (data) {
        // --- Logika Filter Client-Side ---
        final filteredData = data.where((item) {
          final query = searchQuery.toLowerCase();
          return item.name.toLowerCase().contains(query) ||
              item.id.toString().toLowerCase().contains(
                query,
              ) || // <-- Ubah ke toString()
              item.createdAt.toString().toLowerCase().contains(query) ||
              item.updatedAt.toString().toLowerCase().contains(query);
        }).toList();

        // --- Logika Sorting Client-Side ---
        final sortedData = List<TypeEngine>.from(filteredData);
        sortedData.sort((a, b) {
          int result = 0;
          switch (_sortColumnIndex) {
            case 0:
              result = a.id.compareTo(b.id);
              break;
            case 1:
              result = a.name.compareTo(b.name);
              break;
            case 2:
              result = a.createdAt.compareTo(b.createdAt);
              break;
            case 3:
              result = a.updatedAt.compareTo(b.updatedAt);
              break;
          }
          return _sortAscending ? result : -result;
        });
        // ---------------------------------

        return PaginatedDataTable2(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns: _createColumns(),
          source: _TypeEngineDataSource(sortedData, context, ref),
          // loading:  Center(child: CircularProgressIndicator()),
          empty: const Center(child: Text('Tidak ada data ditemukan')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  // Method untuk menangani event klik sort
  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  // Method untuk membuat header kolom
  List<DataColumn2> _createColumns() {
    return [
      DataColumn2(label: const Text('ID'), fixedWidth: 80, onSort: _onSort),
      DataColumn2(
        label: const Text('Type Engine'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Dibuat Pada'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Diupdate Pada'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      const DataColumn2(label: Text('Options'), fixedWidth: 120),
    ];
  }
}

// --- DATA SOURCE ---
class _TypeEngineDataSource extends DataTableSource {
  final List<TypeEngine> data;
  final BuildContext context;
  final WidgetRef ref;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  _TypeEngineDataSource(this.data, this.context, this.ref);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final item = data[index];

    return DataRow(
      cells: [
        DataCell(SelectableText(item.id.toString())), // <-- Ubah ke toString()
        DataCell(SelectableText(item.name)),
        DataCell(SelectableText(dateFormat.format(item.createdAt.toLocal()))),
        DataCell(SelectableText(dateFormat.format(item.updatedAt.toLocal()))),
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
                    .updateTypeEngine(
                      id: item.id,
                      typeEngine: controller.text,
                    ); // <-- ID sudah int
                ref.invalidate(typeEngineListProvider);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data berhasil diupdate'),
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
                    .deleteTypeEngine(id: item.id); // <-- ID sudah int
                ref.invalidate(typeEngineListProvider);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Data berhasil dihapus'),
                    backgroundColor: Colors.orange[400],
                  ),
                );
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
