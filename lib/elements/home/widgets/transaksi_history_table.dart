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
  late final TransaksiDataSource _dataSource;
  int _sortColumnIndex = 9;
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
      // --- PERBAIKAN 1: KURANGI JARAK ANTAR KOLOM ---
      columnSpacing: 3,
      horizontalMargin: 10,
      // border: TableBorder.all(color: Colors.grey.shade300),
      // --- PERBAIKAN 2: MIN WIDTH DIKECILKAN ---
      // Dulu 1600, sekarang 1000. Ini membuat tabel mencoba "memadatkan diri"
      // agar pas di layar 1366px. Jika layar > 1000, dia akan full width tanpa scroll.
      minWidth: 900,

      // Opsi agar header tidak terlalu tinggi
      headingRowHeight: 35,
      dataRowHeight: 30,
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

  // --- PERBAIKAN 3: OPTIMASI UKURAN KOLOM ---
  List<DataColumn2> _createColumns() {
    return [
      // ID: Pendek & Tetap
      DataColumn2(label: const Text('ID'), fixedWidth: 90, onSort: _onSort),

      // Customer: Panjang & Penting (Pake L agar mengambil sisa ruang)
      DataColumn2(
        label: const Text('Customer'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),

      // Data Teknis: Ukuran Sedang/Kecil
      DataColumn2(
        label: const Text('Engine'),
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
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Jenis\nKendaraan'),
        size: ColumnSize.S,
        onSort: _onSort,
      ),

      // Info Status: Kecil
      DataColumn2(
        label: const Text('Jenis\nPengajuan'),
        size: ColumnSize.S,
        onSort: _onSort,
      ),
      DataColumn2(label: const Text('User'), fixedWidth: 70, onSort: _onSort),

      // Tanggal: Fixed Width agar rapi (sekitar 110-120px cukup untuk dd-MM-yyyy HH:mm)
      DataColumn2(
        label: const Text('Created at'),
        fixedWidth: 110,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Updated at'),
        fixedWidth: 110,
        onSort: _onSort,
      ),

      // Option: Fixed Width
      const DataColumn2(label: Text('Options'), fixedWidth: 85),
    ];
  }
}
