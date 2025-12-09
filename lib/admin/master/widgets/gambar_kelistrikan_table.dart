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
  int _sortColumnIndex = 5;
  bool _sortAscending = false;
  late final GambarKelistrikanDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    // 1. Buat DataSource SEKALI SAJA di sini
    _dataSource = GambarKelistrikanDataSource(ref, context);
  }

  @override
  Widget build(BuildContext context) {
    final rowsPerPage = ref.watch(gambarKelistrikanRowsPerPageProvider);

    // 2. PASANG LISTENER DI SINI (Di dalam build)
    ref.listen(gambarKelistrikanFilterProvider, (_, __) {
      _dataSource.refreshDatasource();
    });

    return AsyncPaginatedDataTable2(
      columnSpacing: 3,
      horizontalMargin: 10,
      minWidth: 900,
      headingRowHeight: 35,
      dataRowHeight: 30,
      rowsPerPage: rowsPerPage,
      availableRowsPerPage: const [50, 100, 200],
      onRowsPerPageChanged: (value) {
        if (value != null) {
          ref.read(gambarKelistrikanRowsPerPageProvider.notifier).state = value;
        }
      },
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      columns: _createColumns(),
      source: _dataSource,
      loading: const Center(child: CircularProgressIndicator()),
      empty: const Center(child: Text('Tidak ada data ditemukan')),
    );
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });

    // Mapping sesuai indexFiles di backend
    final Map<int, String> columnMapping = {
      0: 'id',
      1: 'type_engine',
      2: 'merk',
      3: 'type_chassis',
      4: 'created_at',
      5: 'updated_at',
    };

    ref
        .read(gambarKelistrikanFilterProvider.notifier)
        .update(
          (state) => {
            ...state,
            'sortBy': columnMapping[columnIndex] ?? 'updated_at',
            'sortDirection': ascending ? 'asc' : 'desc',
          },
        );
  }

  List<DataColumn2> _createColumns() {
    return [
      DataColumn2(label: const Text('ID'), fixedWidth: 42, onSort: _onSort),
      DataColumn2(
        label: const Text('Type\nEngine'),
        size: ColumnSize.S,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Merk'),
        size: ColumnSize.S,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Type Chassis'),
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
      const DataColumn2(label: Text('Options'), fixedWidth: 122),
    ];
  }
}
