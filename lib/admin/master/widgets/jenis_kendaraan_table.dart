// File: lib/admin/master/widgets/jenis_kendaraan_table.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'jenis_kendaraan_datasource.dart';

class JenisKendaraanTable extends ConsumerStatefulWidget {
  const JenisKendaraanTable({super.key});

  @override
  ConsumerState<JenisKendaraanTable> createState() =>
      _JenisKendaraanTableState();
}

class _JenisKendaraanTableState extends ConsumerState<JenisKendaraanTable> {
  // --- PERUBAHAN 2: Buat state lokal untuk sorting ---
  int _sortColumnIndex = 0; // Default: ID
  bool _sortAscending = true; // Default: asc

  @override
  Widget build(BuildContext context) {
    final dataSource = JenisKendaraanDataSource(ref, context);
    final rowsPerPage = ref.watch(jenisKendaraanRowsPerPageProvider);

    return AsyncPaginatedDataTable2(
      rowsPerPage: rowsPerPage,
      availableRowsPerPage: const [25, 50, 100],
      onRowsPerPageChanged: (value) {
        if (value != null) {
          ref.read(jenisKendaraanRowsPerPageProvider.notifier).state = value;
        }
      },
      // --- PERUBAHAN 3: Hubungkan state ke AsyncPaginatedDataTable2 ---
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      // -----------------------------------------------------------
      columns: _createColumns(),
      source: dataSource,
      loading: const Center(child: CircularProgressIndicator()),
      empty: const Center(child: Text('Tidak ada data ditemukan')),
    );
  }

  // --- PERUBAHAN 4: Ganti logika _createColumns dan tambahkan _onSort ---
  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });

    ref.read(jenisKendaraanFilterProvider.notifier).update((state) {
      final Map<int, String> columnMapping = {
        0: 'id',
        1: 'jenis_kendaraan',
        // Index 2 & 3 dihapus
        2: 'created_at', // Geser index
        3: 'updated_at', // Geser index
      };
      return {
        ...state,
        'sortBy': columnMapping[columnIndex] ?? 'id',
        'sortDirection': ascending ? 'asc' : 'desc',
      };
    });
  }

  List<DataColumn2> _createColumns() {
    return [
      DataColumn2(label: const Text('ID'), fixedWidth: 80, onSort: _onSort),
      DataColumn2(
        label: const Text('Jenis Kendaraan'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),
      // Hapus Merk dan Type Chassis
      DataColumn2(
        label: const Text('Dibuat Pada'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Diupdate Pada'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      const DataColumn2(label: Text('Options'), fixedWidth: 120),
    ];
  }
}
