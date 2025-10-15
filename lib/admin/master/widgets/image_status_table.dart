// File: lib/admin/master/widgets/image_status_table.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'image_status_datasource.dart';

class ImageStatusTable extends ConsumerStatefulWidget {
  const ImageStatusTable({super.key});

  @override
  ConsumerState<ImageStatusTable> createState() => _ImageStatusTableState();
}

class _ImageStatusTableState extends ConsumerState<ImageStatusTable> {
  // State lokal untuk mengelola tampilan panah sort di UI
  int _sortColumnIndex = 6; // Default: Updated At Gbr. Utama
  bool _sortAscending = false; // Default: Terbaru di atas (desc)

  @override
  Widget build(BuildContext context) {
    final source = ref.watch(imageStatusSourceProvider);
    final rowsPerPage = ref.watch(imageStatusRowsPerPageProvider);

    return AsyncPaginatedDataTable2(
      loading: const Center(child: CircularProgressIndicator()),
      rowsPerPage: rowsPerPage,
      availableRowsPerPage: const [25, 50, 100],
      onRowsPerPageChanged: (value) {
        if (value != null) {
          ref.read(imageStatusRowsPerPageProvider.notifier).state = value;
        }
      },
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      columns: _createColumns(),
      source: source,
      empty: const Center(child: Text('Tidak ada data ditemukan')),
    );
  }

  void _onSort(int columnIndex, bool ascending) {
    // Mapping antara index kolom di UI dengan nama kolom di backend
    final Map<int, String> columnMapping = {
      0: 'type_engine',
      1: 'merk',
      2: 'type_chassis',
      3: 'jenis_kendaraan',
      4: 'varian_body',
      6: 'gambar_utama_updated_at',
      8: 'gambar_optional_updated_at',
    };

    // 1. Update state lokal untuk mengubah tampilan panah di UI
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });

    // 2. Update provider filter untuk mengirim request baru ke server
    ref.read(imageStatusFilterProvider.notifier).update((state) {
      return {
        ...state,
        'sortBy':
            columnMapping[columnIndex] ??
            'gambar_utama_updated_at', // Default sort baru
        'sortDirection': ascending ? 'asc' : 'desc',
      };
    });
  }

  // Method untuk membuat header kolom
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
      DataColumn2(
        label: const Text('Varian Body'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),
      const DataColumn2(
        label: Center(child: Text('Gbr. Utama')),
        fixedWidth: 100,
      ),
      DataColumn2(
        label: const Text('Updated At'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      const DataColumn2(
        label: Center(child: Text('Gbr. Optional')),
        fixedWidth: 100,
      ),
      DataColumn2(
        label: const Text('Updated At'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
    ];
  }
}
