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
  int _sortColumnIndex = 8; // Default sort: updated_at
  bool _sortAscending = false; // Default: desc

  @override
  Widget build(BuildContext context) {
    // Gunakan WidgetRef yang benar dari context
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

    // Mapping ke nama kolom backend yang benar (sesuai H_GambarOptionalController)
    final Map<int, String> columnMapping = {
      0: 'type_engine',
      1: 'merk',
      2: 'type_chassis',
      3: 'jenis_kendaraan',
      4: 'varian_body',
      5: 'tipe',
      6: 'deskripsi',
      7: 'created_at',
      8: 'updated_at',
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
      DataColumn2(
        label: const Text('Type\nEngine'),
        fixedWidth: 122,
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
      DataColumn2(
        label: const Text('Varian Body'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),
      DataColumn2(label: const Text('Tipe'), fixedWidth: 144, onSort: _onSort),
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
      const DataColumn2(label: Text('Options'), fixedWidth: 149),
    ];
  }
}
