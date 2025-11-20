// File: lib/admin/master/widgets/image_status_table.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/models/g_gambar_utama.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'image_status_datasource.dart';
import 'gambar_utama_viewer_dialog.dart'; // Pastikan import file dialog Anda benar

class ImageStatusTable extends ConsumerStatefulWidget {
  const ImageStatusTable({super.key});

  @override
  ConsumerState<ImageStatusTable> createState() => _ImageStatusTableState();
}

class _ImageStatusTableState extends ConsumerState<ImageStatusTable> {
  int _sortColumnIndex = 7;
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    // Buat instance dari class wrapper di bawah
    // ref di sini adalah WidgetRef, cocok dengan konstruktor DataSource yang baru kita ubah
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
    final Map<int, String> columnMapping = {
      0: 'type_engine',
      1: 'merk',
      2: 'type_chassis',
      3: 'jenis_kendaraan',
      4: 'varian_body',
      7: 'updated_at',
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
      const DataColumn2(
        label: Text('Gbr. Optional (Paket)'),
        size: ColumnSize.L,
      ),
      DataColumn2(
        label: const Text('Updated At'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      const DataColumn2(label: Text('Action'), fixedWidth: 80),
    ];
  }
}

// --- WRAPPER CLASS UNTUK MENANGANI DIALOG ---
class _ImageStatusDataSourceWithContext extends ImageStatusDataSource {
  final BuildContext _context;

  // Constructor menerima WidgetRef dan BuildContext
  _ImageStatusDataSourceWithContext(super.ref, this._context);

  @override
  void showPreviewDialog(GGambarUtama gambarUtama) {
    // Membuka GambarUtamaViewerDialog yang kodenya Anda berikan sebelumnya
    showDialog(
      context: _context,
      builder: (_) => GambarUtamaViewerDialog(gambarUtama: gambarUtama),
    );
  }
}
