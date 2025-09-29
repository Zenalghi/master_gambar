import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/master/models/type_chassis.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:dio/dio.dart';
import '../repository/master_data_repository.dart';

// 1. Ubah menjadi ConsumerStatefulWidget
class TypeChassisTable extends ConsumerStatefulWidget {
  const TypeChassisTable({super.key});

  @override
  ConsumerState<TypeChassisTable> createState() => _TypeChassisTableState();
}

class _TypeChassisTableState extends ConsumerState<TypeChassisTable> {
  // 2. Tambahkan state untuk sorting (default sort by ID)
  int? _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(typeChassisListProvider);
    final rowsPerPage = ref.watch(typeChassisRowsPerPageProvider);
    final searchQuery = ref.watch(typeChassisSearchQueryProvider);

    return asyncData.when(
      data: (data) {
        final filteredData = data.where((item) {
          final query = searchQuery.toLowerCase();
          return item.name.toLowerCase().contains(query) ||
              item.id.toLowerCase().contains(query) ||
              item.merk.name.toLowerCase().contains(query) ||
              item.merk.typeEngine.name.toLowerCase().contains(query);
        }).toList();

        // 3. Tambahkan logika sorting
        final sortedData = List<TypeChassis>.from(filteredData);
        if (_sortColumnIndex != null) {
          sortedData.sort((a, b) {
            late final Comparable<Object> cellA;
            late final Comparable<Object> cellB;
            switch (_sortColumnIndex!) {
              case 0:
                cellA = a.id;
                cellB = b.id;
                break;
              case 1:
                cellA = a.name.toLowerCase();
                cellB = b.name.toLowerCase();
                break;
              case 2:
                cellA = a.merk.name.toLowerCase();
                cellB = b.merk.name.toLowerCase();
                break;
              case 3:
                cellA = a.createdAt;
                cellB = b.createdAt;
                break;
              case 4:
                cellA = a.updatedAt;
                cellB = b.updatedAt;
                break;
              default:
                return 0;
            }
            return _sortAscending
                ? cellA.compareTo(cellB)
                : cellB.compareTo(cellA);
          });
        }

        return PaginatedDataTable2(
          rowsPerPage: rowsPerPage,
          availableRowsPerPage: const [10, 25, 50, 100],
          onRowsPerPageChanged: (value) {
            if (value != null) {
              ref.read(typeChassisRowsPerPageProvider.notifier).state = value;
            }
          },
          // 4. Hubungkan state ke tabel
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns: _createColumns(),
          source: _TypeChassisDataSource(sortedData, context, ref),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  // 5. Buat method untuk header kolom
  List<DataColumn2> _createColumns() {
    return [
      DataColumn2(label: const Text('ID'), fixedWidth: 120, onSort: _onSort),
      DataColumn2(
        label: const Text('Type Chassis'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Merk (Induk)'),
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

  // 6. Buat method untuk mengelola state sort
  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }
}

class _TypeChassisDataSource extends DataTableSource {
  final List<TypeChassis> data;
  final BuildContext context;
  final WidgetRef ref;
  _TypeChassisDataSource(this.data, this.context, this.ref);

  @override
  DataRow? getRow(int index) {
    final item = data[index];
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    return DataRow(
      cells: [
        DataCell(Text(item.id)),
        DataCell(Text(item.name)),
        DataCell(Text('${item.merk.name} (${item.merk.id})')),
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
              await ref
                  .read(masterDataRepositoryProvider)
                  .updateTypeChassis(id: item.id, typeChassis: controller.text);
              ref.invalidate(typeChassisListProvider);
              Navigator.of(context).pop();
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
                await ref
                    .read(masterDataRepositoryProvider)
                    .deleteTypeChassis(id: item.id);
                ref.invalidate(typeChassisListProvider);
                Navigator.of(context).pop();
              } on DioException catch (e) {
                final message =
                    e.response?.data['errors']?['general']?[0] ??
                    'Terjadi kesalahan.';
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
