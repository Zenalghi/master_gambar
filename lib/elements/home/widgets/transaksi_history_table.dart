// File: lib/elements/home/widgets/transaksi_history_table.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/elements/home/providers/transaksi_providers.dart';
import 'transaksi_history_datasource.dart';

class TransaksiHistoryTable extends ConsumerStatefulWidget {
  const TransaksiHistoryTable({super.key});

  @override
  ConsumerState<TransaksiHistoryTable> createState() =>
      _TransaksiHistoryTableState();
}

class _TransaksiHistoryTableState extends ConsumerState<TransaksiHistoryTable> {
  late final TransaksiDataSource _dataSource; // Instance persisten
  int _sortColumnIndex = 9;
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    // 1. Buat DataSource sekali saja di sini
    _dataSource = TransaksiDataSource(ref, context);
  }

  @override
  Widget build(BuildContext context) {
    final rowsPerPage = ref.watch(rowsPerPageProvider);

    // 2. DENGARKAN PERUBAHAN FILTER DI SINI
    // Ini akan memicu refresh pada DataSource yang sama
    ref.listen(transaksiFilterProvider, (_, __) {
      _dataSource.refreshDatasource();
    });

    return AsyncPaginatedDataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 1600,
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      rowsPerPage: rowsPerPage,
      availableRowsPerPage: const [25, 50, 100],
      onRowsPerPageChanged: (value) {
        if (value != null) {
          ref.read(rowsPerPageProvider.notifier).state = value;
        }
      },
      columns: _createColumns(),
      source: _dataSource, // Gunakan instance yang dibuat di initState
      loading: const Center(child: CircularProgressIndicator()),
      empty: const Center(child: Text('Tidak ada data ditemukan')),
    );
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });

    final Map<int, String> columnMapping = {
      0: 'id',
      1: 'customer',
      2: 'type_engine',
      3: 'merk',
      4: 'type_chassis',
      5: 'jenis_kendaraan',
      6: 'jenis_pengajuan',
      7: 'user',
      8: 'created_at',
      9: 'updated_at',
    };

    ref.read(transaksiFilterProvider.notifier).update((state) {
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
        label: const Text('ID Transaksi'),
        size: ColumnSize.S,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Customer'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Type Engine'),
        size: ColumnSize.S,
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
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Jenis\nPengajuan'),
        size: ColumnSize.S,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('User'),
        size: ColumnSize.S,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Created At'),
        size: ColumnSize.S,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Updated At'),
        size: ColumnSize.S,
        onSort: _onSort,
      ),
      const DataColumn2(label: Text('Option'), fixedWidth: 100),
    ];
  }
}
