import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/master_data_providers.dart';
import 'master_varian_datasource.dart';

class MasterVarianTable extends ConsumerStatefulWidget {
  const MasterVarianTable({super.key});

  @override
  ConsumerState<MasterVarianTable> createState() => _MasterVarianTableState();
}

class _MasterVarianTableState extends ConsumerState<MasterVarianTable> {
  int _sortColumnIndex = 4; // Default: updated_at
  bool _sortAscending = false;

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });

    final Map<int, String> columnMapping = {
      0: 'id',
      1: 'jenis_kendaraan',
      2: 'nama_varian',
      3: 'created_at',
      4: 'updated_at',
    };

    ref.read(masterVarianFilterProvider.notifier).update((state) {
      return {
        ...state,
        'sortBy': columnMapping[columnIndex] ?? 'updated_at',
        'sortDirection': ascending ? 'asc' : 'desc',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataSource = MasterVarianDataSource(ref, context);
    final rowsPerPage = ref.watch(masterVarianRowsPerPageProvider);

    return AsyncPaginatedDataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 800,
      headingRowHeight: 35,
      dataRowHeight: 32,
      rowsPerPage: rowsPerPage,
      availableRowsPerPage: const [50, 100],
      onRowsPerPageChanged: (value) {
        if (value != null) {
          ref.read(masterVarianRowsPerPageProvider.notifier).state = value;
        }
      },
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      columns: [
        DataColumn2(label: const Text('ID'), fixedWidth: 50, onSort: _onSort),
        DataColumn2(
          label: const Text('Jenis Kendaraan'),
          size: ColumnSize.L,
          onSort: _onSort,
        ),
        DataColumn2(
          label: const Text('Nama Varian'),
          size: ColumnSize.L,
          onSort: _onSort,
        ),
        DataColumn2(
          label: const Text('Created At'),
          fixedWidth: 120,
          onSort: _onSort,
        ),
        DataColumn2(
          label: const Text('Updated At'),
          fixedWidth: 120,
          onSort: _onSort,
        ),
        const DataColumn2(label: Text('Options'), fixedWidth: 90),
      ],
      source: dataSource,
      loading: const Center(child: CircularProgressIndicator()),
      empty: const Center(
        child: Text(
          'Tidak ada data Master Varian.\nSilakan tambah baru atau gunakan fitur pencarian.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ),
    );
  }
}
