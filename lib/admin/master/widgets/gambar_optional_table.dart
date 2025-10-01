// File: lib/admin/master/widgets/gambar_optional_table.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:master_gambar/admin/master/models/gambar_optional.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'edit_gambar_optional_dialog.dart'; // Import dialog edit

class GambarOptionalDataSource extends DataTableSource {
  final BuildContext context;
  final WidgetRef ref;
  final List<GambarOptional> data;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  GambarOptionalDataSource(this.context, this.ref, this.data);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final item = data[index];
    final varianBody = item.varianBody;
    final jenisKendaraan = varianBody.jenisKendaraan;
    final typeChassis = jenisKendaraan.typeChassis;
    final merk = typeChassis.merk;
    final typeEngine = merk.typeEngine;

    return DataRow2(
      key: ValueKey(item.id),
      cells: [
        DataCell(Text(typeEngine.name)),
        DataCell(Text(merk.name)),
        DataCell(Text(typeChassis.name)),
        DataCell(Text(jenisKendaraan.name)),
        DataCell(Text(varianBody.name)),
        DataCell(Text(item.deskripsi)),
        DataCell(Text(dateFormat.format(item.createdAt.toLocal()))),
        DataCell(Text(dateFormat.format(item.updatedAt.toLocal()))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.orange.shade700),
                tooltip: 'Edit Deskripsi',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) =>
                        EditGambarOptionalDialog(gambarOptional: item),
                  );
                },
              ),
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
  }

  void _showDeleteConfirmation(GambarOptional item) {
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
      await ref.read(masterDataRepositoryProvider).deleteGambarOptional(id: id);
      ref.invalidate(gambarOptionalListProvider);
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

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => data.length;
  @override
  int get selectedRowCount => 0;
}

class GambarOptionalTable extends ConsumerStatefulWidget {
  const GambarOptionalTable({super.key});
  @override
  ConsumerState<GambarOptionalTable> createState() =>
      _GambarOptionalTableState();
}

class _GambarOptionalTableState extends ConsumerState<GambarOptionalTable> {
  int _sortColumnIndex = 7; // Default sort: Updated At
  bool _sortAscending = false; // Default: Descending (terbaru di atas)

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(gambarOptionalListProvider);
    final searchQuery = ref.watch(gambarOptionalSearchQueryProvider);
    final rowsPerPage = ref.watch(gambarOptionalRowsPerPageProvider);

    return asyncData.when(
      data: (data) {
        final filteredData = data.where((item) {
          final query = searchQuery.toLowerCase();
          if (query.isEmpty) return true;
          return item.varianBody.jenisKendaraan.typeChassis.merk.typeEngine.name
                  .toLowerCase()
                  .contains(query) ||
              item.varianBody.jenisKendaraan.typeChassis.merk.name
                  .toLowerCase()
                  .contains(query) ||
              item.varianBody.jenisKendaraan.typeChassis.name
                  .toLowerCase()
                  .contains(query) ||
              item.varianBody.jenisKendaraan.name.toLowerCase().contains(
                query,
              ) ||
              item.varianBody.name.toLowerCase().contains(query) ||
              item.deskripsi.toLowerCase().contains(query);
        }).toList();

        final sortedData = List<GambarOptional>.from(filteredData)
          ..sort((a, b) {
            final aVarianBody = a.varianBody;
            final bVarianBody = b.varianBody;
            int result = 0;
            switch (_sortColumnIndex) {
              case 0:
                result = aVarianBody
                    .jenisKendaraan
                    .typeChassis
                    .merk
                    .typeEngine
                    .name
                    .compareTo(
                      bVarianBody
                          .jenisKendaraan
                          .typeChassis
                          .merk
                          .typeEngine
                          .name,
                    );
                break;
              case 1:
                result = aVarianBody.jenisKendaraan.typeChassis.merk.name
                    .compareTo(
                      bVarianBody.jenisKendaraan.typeChassis.merk.name,
                    );
                break;
              case 2:
                result = aVarianBody.jenisKendaraan.typeChassis.name.compareTo(
                  bVarianBody.jenisKendaraan.typeChassis.name,
                );
                break;
              case 3:
                result = aVarianBody.jenisKendaraan.name.compareTo(
                  bVarianBody.jenisKendaraan.name,
                );
                break;
              case 4:
                result = aVarianBody.name.compareTo(bVarianBody.name);
                break;
              case 5:
                result = a.deskripsi.compareTo(b.deskripsi);
                break;
              case 6:
                result = a.createdAt.compareTo(b.createdAt);
                break;
              case 7:
                result = a.updatedAt.compareTo(b.updatedAt);
                break;
            }
            return _sortAscending ? result : -result;
          });

        final dataSource = GambarOptionalDataSource(context, ref, sortedData);

        return PaginatedDataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 1600,
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          rowsPerPage: rowsPerPage,
          availableRowsPerPage: const [15, 25, 50],
          onRowsPerPageChanged: (value) {
            if (value != null) {
              ref.read(gambarOptionalRowsPerPageProvider.notifier).state =
                  value;
            }
          },
          columns: _createColumns(),
          source: dataSource,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Gagal memuat data: $err')),
    );
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  List<DataColumn2> _createColumns() {
    return [
      DataColumn2(
        label: const Text('Type Engine'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Merk'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Type Chassis'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Jenis Kendaraan'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Varian Body'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Deskripsi'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Created At'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Updated At'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      const DataColumn2(label: Text('Option'), size: ColumnSize.S),
    ];
  }
}
