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
  late final TransaksiDataSource _dataSource;

  // Default sort updated_at desc (index 10)
  int _sortColumnIndex = 10;
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _dataSource = TransaksiDataSource(ref, context);
  }

  @override
  Widget build(BuildContext context) {
    final rowsPerPage = ref.watch(rowsPerPageProvider);

    ref.listen(transaksiFilterProvider, (_, __) {
      _dataSource.refreshDatasource();
    });

    return AsyncPaginatedDataTable2(
      columnSpacing: 10,
      horizontalMargin: 10,
      minWidth: 1200, // Lebarkan sedikit agar kolom Judul muat
      headingRowHeight: 35,
      dataRowHeight: 30,
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      rowsPerPage: rowsPerPage,
      availableRowsPerPage: const [50, 100],
      onRowsPerPageChanged: (value) {
        if (value != null) {
          ref.read(rowsPerPageProvider.notifier).state = value;
        }
      },
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

    // Mapping Index Kolom ke Nama Field Database
    final Map<int, String> columnMapping = {
      0: 'id',
      1: 'customer',
      2: 'type_engine',
      3: 'merk',
      4: 'type_chassis',
      5: 'jenis_kendaraan',
      6: 'jenis_pengajuan',
      7: 'judul_gambar', // Pastikan backend handle sorting ini (optional)
      8: 'user',
      9: 'created_at',
      10: 'updated_at',
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
      // 0. ID
      DataColumn2(label: const Text('ID'), fixedWidth: 61, onSort: _onSort),

      // 1. Customer
      DataColumn2(
        label: const Text('Customer'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),

      // 2. Engine
      DataColumn2(
        label: const Text('Type\nEngine'),
        fixedWidth: 68,
        onSort: _onSort,
      ),

      // 3. Merk
      DataColumn2(
        label: const Text('Merk'),
        size: ColumnSize.S,
        onSort: _onSort,
      ),

      // 4. Type Chassis
      DataColumn2(
        label: const Text('Type Chassis'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),

      // 5. Jenis Kendaraan
      DataColumn2(
        label: const Text('Jenis\nKendaraan'),
        size: ColumnSize.S,
        onSort: _onSort,
      ),

      // 6. Jenis Pengajuan
      DataColumn2(
        label: const Text('Jenis\nPengajuan'),
        size: ColumnSize.S,
        onSort: _onSort,
      ),

      // 7. Judul Gambar (BARU)
      DataColumn2(
        label: const Text('Judul (Standar, Varian)'),
        size: ColumnSize.L,
        onSort: _onSort, // Sudah diperbaiki dari error _sort
      ),

      // 8. User
      DataColumn2(label: const Text('User'), fixedWidth: 70, onSort: _onSort),

      // 9. Created At
      DataColumn2(
        label: const Text('Created at'),
        fixedWidth: 110,
        onSort: _onSort,
      ),

      // 10. Updated At
      DataColumn2(
        label: const Text('Updated at'),
        fixedWidth: 110,
        onSort: _onSort,
      ),

      // Options
      const DataColumn2(label: Text('Options'), fixedWidth: 85),
    ];
  }
}
