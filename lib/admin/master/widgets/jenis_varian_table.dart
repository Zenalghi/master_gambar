import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/master/models/jenis_varian.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import '../repository/master_data_repository.dart';

class JenisVarianTable extends ConsumerStatefulWidget {
  const JenisVarianTable({super.key});
  @override
  ConsumerState<JenisVarianTable> createState() => _JenisVarianTableState();
}

class _JenisVarianTableState extends ConsumerState<JenisVarianTable> {
  int? _sortColumnIndex = 0; // Default sort by ID
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(jenisVarianListProvider);
    final rowsPerPage = ref.watch(jenisVarianRowsPerPageProvider);
    final searchQuery = ref.watch(jenisVarianSearchQueryProvider);

    return asyncData.when(
      data: (data) {
        final filteredData = data.where((item) {
          final query = searchQuery.toLowerCase();
          return item.name.toLowerCase().contains(query) ||
              item.id.toString().contains(query);
        }).toList();

        final sortedData = List<JenisVarian>.from(filteredData);
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
                cellA = a.createdAt;
                cellB = b.createdAt;
                break;
              case 3:
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
          availableRowsPerPage: const [13, 25, 50],
          onRowsPerPageChanged: (value) =>
              ref.read(jenisVarianRowsPerPageProvider.notifier).state = value!,
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns: _createColumns(),
          source: _JenisVarianDataSource(sortedData, context, ref),
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
        label: const Text('Jenis Varian'),
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

class _JenisVarianDataSource extends DataTableSource {
  final List<JenisVarian> data;
  final BuildContext context;
  final WidgetRef ref;
  _JenisVarianDataSource(this.data, this.context, this.ref);

  @override
  DataRow? getRow(int index) {
    final item = data[index];
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    return DataRow(
      cells: [
        DataCell(Text(item.id.toString())),
        DataCell(Text(item.name)),
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

  void _showEditDialog(JenisVarian item) {
    final controller = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Jenis Varian: ${item.id}'),
        content: TextFormField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Nama Jenis Varian'),
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
                  .updateJenisVarian(id: item.id, namaJudul: controller.text);
              ref.invalidate(jenisVarianListProvider);
              Navigator.of(context).pop();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(JenisVarian item) {
    // ... (logika hapus sama seperti Type Engine)
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => data.length;
  @override
  int get selectedRowCount => 0;
}
