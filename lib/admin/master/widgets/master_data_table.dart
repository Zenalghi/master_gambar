// File: lib/admin/master/widgets/master_data_table.dart
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'master_data_datasource.dart';

class MasterDataTable extends ConsumerStatefulWidget {
  const MasterDataTable({super.key});

  @override
  ConsumerState<MasterDataTable> createState() => _MasterDataTableState();
}

class _MasterDataTableState extends ConsumerState<MasterDataTable> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final dataSource = MasterDataDataSource(ref, context);
    final rowsPerPage = ref.watch(masterDataRowsPerPageProvider);

    return AsyncPaginatedDataTable2(
      loading: const Center(child: CircularProgressIndicator()),
      rowsPerPage: rowsPerPage,
      availableRowsPerPage: const [25, 50, 100],
      onRowsPerPageChanged: (value) =>
          ref.read(masterDataRowsPerPageProvider.notifier).state = value!,
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      columns: _createColumns(),
      source: dataSource,
      empty: const Center(child: Text('Tidak ada data ditemukan')),
    );
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    final Map<int, String> columnMapping = {
      0: 'type_engine',
      1: 'merk',
      2: 'type_chassis',
      3: 'jenis_kendaraan',
    };
    ref
        .read(masterDataFilterProvider.notifier)
        .update(
          (state) => {
            ...state,
            'sortBy': columnMapping[columnIndex] ?? 'id',
            'sortDirection': ascending ? 'asc' : 'desc',
          },
        );
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
      const DataColumn2(
        label: Center(child: Text('Kelistrikan')),
        fixedWidth: 100,
      ),
      const DataColumn2(label: Text('Options'), fixedWidth: 120),
    ];
  }
}
