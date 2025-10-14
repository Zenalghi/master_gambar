import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'varian_body_datasource.dart';

class VarianBodyTable extends ConsumerStatefulWidget {
  const VarianBodyTable({super.key});

  @override
  ConsumerState<VarianBodyTable> createState() => _VarianBodyTableState();
}

class _VarianBodyTableState extends ConsumerState<VarianBodyTable> {
  int _sortColumnIndex = 6; // Default: updated_at
  bool _sortAscending = false; // Default: desc

  @override
  Widget build(BuildContext context) {
    final dataSource = VarianBodyDataSource(ref, context);
    final rowsPerPage = ref.watch(varianBodyRowsPerPageProvider);

    return AsyncPaginatedDataTable2(
      rowsPerPage: rowsPerPage,
      availableRowsPerPage: const [25, 50, 100],
      onRowsPerPageChanged: (value) {
        if (value != null) {
          ref.read(varianBodyRowsPerPageProvider.notifier).state = value;
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

    ref.read(varianBodyFilterProvider.notifier).update((state) {
      final Map<int, String> columnMapping = {
        0: 'id',
        1: 'varian_body',
        2: 'jenis_kendaraan',
        3: 'type_chassis',
        4: 'merk',
        5: 'created_at',
        6: 'updated_at',
      };
      return {
        ...state,
        'sortBy': columnMapping[columnIndex] ?? 'updated_at',
        'sortDirection': ascending ? 'asc' : 'desc',
      };
    });
  }

  List<DataColumn2> _createColumns() {
    return [
      DataColumn2(label: const Text('ID'), fixedWidth: 60, onSort: _onSort),
      DataColumn2(
        label: const Text('Varian Body'),
        size: ColumnSize.S,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Jenis Kendaraan (Induk)'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Type Chassis (Induk)'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Merk (Induk)'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Dibuat Pada'),
        size: ColumnSize.S,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Diupdate Pada'),
        size: ColumnSize.S,
        onSort: _onSort,
      ),
      const DataColumn2(label: Text('Options'), fixedWidth: 120),
    ];
  }
}
