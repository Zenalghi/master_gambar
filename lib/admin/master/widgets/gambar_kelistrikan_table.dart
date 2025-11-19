// File: lib/admin/master/widgets/gambar_kelistrikan_table.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'gambar_kelistrikan_datasource.dart';

class GambarKelistrikanTable extends ConsumerStatefulWidget {
  const GambarKelistrikanTable({super.key});

  @override
  ConsumerState<GambarKelistrikanTable> createState() =>
      _GambarKelistrikanTableState();
}

class _GambarKelistrikanTableState
    extends ConsumerState<GambarKelistrikanTable> {
  int _sortColumnIndex = 5; // Default: updated_at
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    final dataSource = GambarKelistrikanDataSource(ref, context);
    final rowsPerPage = ref.watch(gambarKelistrikanRowsPerPageProvider);

    return AsyncPaginatedDataTable2(
      rowsPerPage: rowsPerPage,
      availableRowsPerPage: const [25, 50, 100],
      onRowsPerPageChanged: (value) {
        if (value != null) {
          ref.read(gambarKelistrikanRowsPerPageProvider.notifier).state = value;
        }
      },
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      columns: _createColumns(),
      source: dataSource,
      loading: const Center(child: CircularProgressIndicator()),
      empty: const Center(child: Text('Tidak ada data ditemukan')),
    );
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });

    ref.read(gambarKelistrikanFilterProvider.notifier).update((state) {
      // Mapping sesuai backend
      final Map<int, String> columnMapping = {
        0: 'type_engine',
        1: 'merk',
        2: 'type_chassis',
        3: 'deskripsi',
        4: 'created_at',
        5: 'updated_at',
      };
      return {
        ...state,
        'sortBy': columnMapping[columnIndex] ?? 'updated_at',
        'sortDirection': ascending ? 'asc' : 'desc',
      };
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
      const DataColumn2(label: Text('Options'), fixedWidth: 120),
    ];
  }
}
