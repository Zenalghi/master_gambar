// File: lib/admin/master/widgets/gambar_optional_table.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'gambar_optional_datasource.dart';

class GambarOptionalTable extends ConsumerStatefulWidget {
  const GambarOptionalTable({super.key});

  @override
  ConsumerState<GambarOptionalTable> createState() =>
      _GambarOptionalTableState();
}

class _GambarOptionalTableState extends ConsumerState<GambarOptionalTable> {
  int _sortColumnIndex = 9; // Default: updated_at (geser +1 karena ada ID)
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    // ... kode build tetap sama
    final dataSource = GambarOptionalDataSource(ref, context);
    final rowsPerPage = ref.watch(gambarOptionalRowsPerPageProvider);

    return AsyncPaginatedDataTable2(
      rowsPerPage: rowsPerPage,
      availableRowsPerPage: const [25, 50, 100],
      onRowsPerPageChanged: (value) {
        if (value != null) {
          ref.read(gambarOptionalRowsPerPageProvider.notifier).state = value;
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

    // Mapping ke nama kolom backend yang benar (sesuai Controller)
    final Map<int, String> columnMapping = {
      0: 'id',
      1: 'type_engine',
      2: 'merk',
      3: 'type_chassis',
      4: 'jenis_kendaraan',
      5: 'varian_body',
      6: 'tipe',
      7: 'deskripsi',
      8: 'created_at',
      9: 'updated_at',
    };

    ref.read(gambarOptionalFilterProvider.notifier).update((state) {
      return {
        ...state,
        'sortBy': columnMapping[columnIndex] ?? 'updated_at',
        'sortDirection': ascending ? 'asc' : 'desc',
      };
    });
  }

  List<DataColumn2> _createColumns() {
    return [
      DataColumn2(label: const Text('ID'), fixedWidth: 59, onSort: _onSort),
      DataColumn2(
        label: const Text('Type\nEngine'),
        fixedWidth: 121,
        onSort: _onSort,
      ),
      DataColumn2(label: const Text('Merk'), fixedWidth: 136, onSort: _onSort),
      DataColumn2(
        label: const Text('Type\nChassis'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Jenis\nKendaraan'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Varian Body'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      DataColumn2(label: const Text('Tipe'), fixedWidth: 144, onSort: _onSort),
      DataColumn2(
        label: const Text('Deskripsi'),
        size: ColumnSize.M,
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
      const DataColumn2(label: Text('Options'), fixedWidth: 149),
    ];
  }
}
