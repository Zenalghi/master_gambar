import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/master/models/gambar_optional.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:dio/dio.dart';
import '../repository/master_data_repository.dart';

class GambarOptionalTable extends ConsumerStatefulWidget {
  const GambarOptionalTable({super.key});
  @override
  ConsumerState<GambarOptionalTable> createState() =>
      _GambarOptionalTableState();
}

class _GambarOptionalTableState extends ConsumerState<GambarOptionalTable> {
  int? _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(gambarOptionalListProvider);
    final rowsPerPage = ref.watch(gambarOptionalRowsPerPageProvider);
    final searchQuery = ref.watch(gambarOptionalSearchQueryProvider);

    return Card(
      child: asyncData.when(
        data: (data) {
          final filteredData = data.where((item) {
            final query = searchQuery.toLowerCase();
            return item.deskripsi.toLowerCase().contains(query) ||
                item.varianBody.name.toLowerCase().contains(query) ||
                item.varianBody.jenisKendaraan.name.toLowerCase().contains(
                  query,
                );
          }).toList();

          final sortedData = List<GambarOptional>.from(filteredData);
          if (_sortColumnIndex != null) {
            // Logika sorting ditambahkan di sini
            
          }

          return PaginatedDataTable2(
            rowsPerPage: rowsPerPage,
            availableRowsPerPage: const [10, 25, 50, 100],
            onRowsPerPageChanged: (value) =>
                ref.read(gambarOptionalRowsPerPageProvider.notifier).state =
                    value!,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            columns: _createColumns(),
            source: _GambarOptionalDataSource(sortedData, context, ref),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  List<DataColumn2> _createColumns() {
    return const [
      DataColumn2(label: Text('Type Engine'), size: ColumnSize.M),
      DataColumn2(label: Text('Merk'), size: ColumnSize.M),
      DataColumn2(label: Text('Type Chassis'), size: ColumnSize.L),
      DataColumn2(label: Text('Jenis Kendaraan'), size: ColumnSize.L),
      DataColumn2(label: Text('Varian Body'), size: ColumnSize.L),
      DataColumn2(label: Text('Deskripsi'), size: ColumnSize.L),
      DataColumn2(label: Text('Dibuat Pada'), size: ColumnSize.M),
      DataColumn2(label: Text('Diupdate Pada'), size: ColumnSize.M),
      DataColumn2(label: Text('Options'), fixedWidth: 120),
    ];
  }
}

class _GambarOptionalDataSource extends DataTableSource {
  final List<GambarOptional> data;
  final BuildContext context;
  final WidgetRef ref;
  _GambarOptionalDataSource(this.data, this.context, this.ref);

  @override
  DataRow? getRow(int index) {
    final item = data[index];
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final varian = item.varianBody;
    final jenis = varian.jenisKendaraan;
    final chassis = jenis.typeChassis;
    final merk = chassis.merk;
    final engine = merk.typeEngine;

    return DataRow(
      cells: [
        DataCell(Text(engine.name)),
        DataCell(Text(merk.name)),
        DataCell(Text(chassis.name)),
        DataCell(Text(jenis.name)),
        DataCell(Text(varian.name)),
        DataCell(Text(item.deskripsi)),
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

  void _showEditDialog(GambarOptional item) {
    final controller = TextEditingController(text: item.deskripsi);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Deskripsi: ${item.id}'),
        content: TextFormField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Deskripsi'),
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
                  .updateGambarOptional(
                    id: item.id,
                    deskripsi: controller.text,
                  );
              ref.invalidate(gambarOptionalListProvider);
              Navigator.of(context).pop();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(GambarOptional item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Anda yakin ingin menghapus "${item.deskripsi}"?'),
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
                    .deleteGambarOptional(id: item.id);
                ref.invalidate(gambarOptionalListProvider);
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
