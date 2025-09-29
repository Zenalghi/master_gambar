import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/master/models/varian_body.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:dio/dio.dart';
import '../repository/master_data_repository.dart';

class VarianBodyTable extends ConsumerStatefulWidget {
  const VarianBodyTable({super.key});

  @override
  ConsumerState<VarianBodyTable> createState() => _VarianBodyTableState();
}

class _VarianBodyTableState extends ConsumerState<VarianBodyTable> {
  // Default sort: Kolom 'Varian Body' (index 1), Ascending (A-Z)
  int? _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(varianBodyListProvider);
    final rowsPerPage = ref.watch(varianBodyRowsPerPageProvider);
    final searchQuery = ref.watch(varianBodySearchQueryProvider);

    return asyncData.when(
      data: (data) {
        final filteredData = data.where((item) {
          final query = searchQuery.toLowerCase();
          return item.name.toLowerCase().contains(query) ||
              item.id.toString().toLowerCase().contains(query) ||
              item.jenisKendaraan.name.toLowerCase().contains(query) ||
              item.jenisKendaraan.typeChassis.name.toLowerCase().contains(
                query,
              ) ||
              item.jenisKendaraan.typeChassis.merk.name.toLowerCase().contains(
                query,
              ) ||
              item.jenisKendaraan.typeChassis.merk.typeEngine.name
                  .toLowerCase()
                  .contains(query);
        }).toList();

        final sortedData = List<VarianBody>.from(filteredData);
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
                cellA = a.jenisKendaraan.name.toLowerCase();
                cellB = b.jenisKendaraan.name.toLowerCase();
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
              ref.read(varianBodyRowsPerPageProvider.notifier).state = value;
            }
          },
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns: _createColumns(),
          source: _VarianBodyDataSource(sortedData, context, ref),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  List<DataColumn2> _createColumns() {
    return [
      DataColumn2(label: const Text('ID'), fixedWidth: 80, onSort: _onSort),
      DataColumn2(
        label: const Text('Varian Body'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Jenis Kendaraan (Induk)'),
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

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }
}

class _VarianBodyDataSource extends DataTableSource {
  final List<VarianBody> data;
  final BuildContext context;
  final WidgetRef ref;
  _VarianBodyDataSource(this.data, this.context, this.ref);

  @override
  DataRow? getRow(int index) {
    final item = data[index];
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    return DataRow(
      cells: [
        DataCell(Text(item.id.toString())),
        DataCell(Text(item.name)),
        DataCell(
          Text('${item.jenisKendaraan.name} (${item.jenisKendaraan.id})'),
        ),
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

  void _showEditDialog(VarianBody item) {
    final controller = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Varian Body: ${item.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Induk: ${item.jenisKendaraan.name}'),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Nama Varian Body'),
            ),
          ],
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
                  .updateVarianBody(
                    id: item.id,
                    jenisKendaraanId: item.jenisKendaraan.id,
                    varianBody: controller.text,
                  );
              ref.invalidate(varianBodyListProvider);
              Navigator.of(context).pop();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
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
                await ref
                    .read(masterDataRepositoryProvider)
                    .deleteVarianBody(id: item.id);
                ref.invalidate(varianBodyListProvider);
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
