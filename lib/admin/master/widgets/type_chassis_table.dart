import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'type_chassis_datasource.dart';

class TypeChassisTable extends ConsumerStatefulWidget {
  const TypeChassisTable({super.key});

  @override
  ConsumerState<TypeChassisTable> createState() => _TypeChassisTableState();
}

class _TypeChassisTableState extends ConsumerState<TypeChassisTable> {
  int _sortColumnIndex = 0; // ID
  bool _sortAscending = true; // asc

  @override
  Widget build(BuildContext context) {
    final dataSource = TypeChassisDataSource(ref, context);
    final rowsPerPage = ref.watch(typeChassisRowsPerPageProvider);

    return AsyncPaginatedDataTable2(
      rowsPerPage: rowsPerPage,
      availableRowsPerPage: const [25, 50, 100],
      onRowsPerPageChanged: (value) {
        if (value != null) {
          ref.read(typeChassisRowsPerPageProvider.notifier).state = value;
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

    ref.read(typeChassisFilterProvider.notifier).update((state) {
      final Map<int, String> columnMapping = {
        0: 'id',
        1: 'type_chassis',
        2: 'merk',
        3: 'created_at',
        4: 'updated_at',
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
      DataColumn2(label: const Text('ID'), fixedWidth: 100, onSort: _onSort),
      DataColumn2(
        label: const Text('Type Chassis'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Merk (Induk)'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),
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
