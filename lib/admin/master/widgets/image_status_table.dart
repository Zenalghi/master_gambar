// File: lib/admin/master/widgets/image_status_table.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/models/g_gambar_utama.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'image_status_datasource.dart';
import 'gambar_utama_viewer_dialog.dart';

class ImageStatusTable extends ConsumerStatefulWidget {
  const ImageStatusTable({super.key});

  @override
  ConsumerState<ImageStatusTable> createState() => _ImageStatusTableState();
}

class _ImageStatusTableState extends ConsumerState<ImageStatusTable> {
  int _sortColumnIndex = 7; // Default sort: Updated At (index ke-7 sekarang)
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    final dataSource = _ImageStatusDataSourceWithContext(ref, context);
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
      source: dataSource,
      empty: const Center(child: Text('Tidak ada data ditemukan')),
    );
  }

  void _onSort(int columnIndex, bool ascending) {
    // Mapping index kolom UI ke field database
    final Map<int, String> columnMapping = {
      0: 'id', // ID Varian Body
      1: 'type_engine',
      2: 'merk',
      3: 'type_chassis',
      4: 'jenis_kendaraan',
      5: 'varian_body',
      7: 'updated_at', // Kolom Updated At Gambar Utama
      8: 'deskripsi_optional', // Kolom Gbr Optional
    };

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });

    ref.read(imageStatusFilterProvider.notifier).update((state) {
      return {
        ...state,
        'sortBy': columnMapping[columnIndex] ?? 'updated_at',
        'sortDirection': ascending ? 'asc' : 'desc',
      };
    });
  }

  List<DataColumn2> _createColumns() {
    return [
      // 1. ID Varian Body
      DataColumn2(label: const Text('ID'), fixedWidth: 60, onSort: _onSort),

      // 2. Type Engine
      DataColumn2(
        label: const Text('Type\nEngine'),
        fixedWidth: 122,
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
        label: const Text('Jenis Kendaraan'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),

      // 6. Varian Body
      DataColumn2(
        label: const Text('Varian Body'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),

      // 7. Gbr Utama (Action Column)
      const DataColumn2(
        label: Center(child: Text('Gbr\nUtama', textAlign: TextAlign.center)),
        fixedWidth: 120,
      ),

      // 8. Updated At
      DataColumn2(
        label: const Text('Updated At'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),

      // 9. Gbr. Optional Paket
      DataColumn2(
        label: const Text('Gbr. Optional\nPaket'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
    ];
  }
}

// Wrapper untuk dialog preview
class _ImageStatusDataSourceWithContext extends ImageStatusDataSource {
  final BuildContext _context;
  _ImageStatusDataSourceWithContext(super.ref, this._context);

  @override
  void showPreviewDialog(GGambarUtama gambarUtama) {
    showDialog(
      context: _context,
      builder: (_) => GambarUtamaViewerDialog(gambarUtama: gambarUtama),
    );
  }
}
