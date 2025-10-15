// File: lib/admin/master/widgets/gambar_kelistrikan_table.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'gambar_kelistrikan_datasource.dart';

class GambarKelistrikanTable extends ConsumerWidget {
  const GambarKelistrikanTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataSource = GambarKelistrikanDataSource(ref, context);
    final rowsPerPage = ref.watch(gambarKelistrikanRowsPerPageProvider);
    final sortState = ref.watch(gambarKelistrikanFilterProvider);
    final sortColumnIndex = _getColumnIndex(sortState['sortBy']);
    final sortAscending = sortState['sortDirection'] == 'asc';

    return AsyncPaginatedDataTable2(
      rowsPerPage: rowsPerPage,
      availableRowsPerPage: const [25, 50, 100],
      onRowsPerPageChanged: (value) {
        if (value != null) {
          ref.read(gambarKelistrikanRowsPerPageProvider.notifier).state = value;
        }
      },
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
      columns: _createColumns(ref),
      source: dataSource,
      loading: const Center(child: CircularProgressIndicator()),
      empty: const Center(child: Text('Tidak ada data ditemukan')),
    );
  }

  int _getColumnIndex(String? sortBy) {
    switch (sortBy) {
      case 'type_engine':
        return 0;
      case 'merk':
        return 1;
      case 'type_chassis':
        return 2;
      case 'deskripsi':
        return 3;
      case 'created_at':
        return 4;
      case 'updated_at':
        return 5;
      default:
        return 5;
    }
  }

  void _onSort(WidgetRef ref, String columnName) {
    ref.read(gambarKelistrikanFilterProvider.notifier).update((state) {
      final currentSortBy = state['sortBy'];
      final currentDirection = state['sortDirection'];
      final newDirection =
          (currentSortBy == columnName && currentDirection == 'asc')
          ? 'desc'
          : 'asc';
      return {...state, 'sortBy': columnName, 'sortDirection': newDirection};
    });
  }

  List<DataColumn2> _createColumns(WidgetRef ref) {
    return [
      DataColumn2(
        label: const Text('Type\nEngine'),
        fixedWidth: 100,
        onSort: (i, a) => _onSort(ref, 'type_engine'),
      ),
      DataColumn2(
        label: const Text('Merk'),
        fixedWidth: 175,
        onSort: (i, a) => _onSort(ref, 'merk'),
      ),
      DataColumn2(
        label: const Text('Type Chassis'),
        size: ColumnSize.M,
        onSort: (i, a) => _onSort(ref, 'type_chassis'),
      ),
      DataColumn2(
        label: const Text('Deskripsi'),
        size: ColumnSize.M,
        onSort: (i, a) => _onSort(ref, 'deskripsi'),
      ),
      DataColumn2(
        label: const Text('Created At'),
        size: ColumnSize.S,
        onSort: (i, a) => _onSort(ref, 'created_at'),
      ),
      DataColumn2(
        label: const Text('Updated At'),
        size: ColumnSize.S,
        onSort: (i, a) => _onSort(ref, 'updated_at'),
      ),
      const DataColumn2(label: Text('Options'), fixedWidth: 120),
    ];
  }
}
