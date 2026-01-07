// File: lib/admin/master/widgets/image_status_table.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/models/g_gambar_utama.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import '../models/image_status.dart';
import '../repository/master_data_repository.dart';
import 'image_status_datasource.dart';
import 'gambar_utama_viewer_dialog.dart';

class ImageStatusTable extends ConsumerStatefulWidget {
  const ImageStatusTable({super.key});

  @override
  ConsumerState<ImageStatusTable> createState() => _ImageStatusTableState();
}

class _ImageStatusTableState extends ConsumerState<ImageStatusTable> {
  // Sesuaikan default UI dengan Provider (ID Descending)
  int _sortColumnIndex = 0;
  bool _sortAscending = false;
  late final _ImageStatusDataSourceWithContext _dataSource;

  @override
  void initState() {
    super.initState();
    _dataSource = _ImageStatusDataSourceWithContext(ref, context);

    // TRICK: Pancing datasource untuk refresh setelah widget selesai dibangun
    Future.microtask(() => _dataSource.refreshDatasource());
  }

  @override
  Widget build(BuildContext context) {
    final rowsPerPage = ref.watch(imageStatusRowsPerPageProvider);

    // PERBAIKAN: Pindahkan listen ke sini (di dalam build)
    ref.listen(imageStatusFilterProvider, (_, __) {
      _dataSource.refreshDatasource();
    });

    return AsyncPaginatedDataTable2(
      columnSpacing: 3,
      horizontalMargin: 10,
      minWidth: 900,
      headingRowHeight: 35,
      dataRowHeight: 30,
      rowsPerPage: rowsPerPage,
      availableRowsPerPage: const [50, 100],
      onRowsPerPageChanged: (value) {
        if (value != null) {
          ref.read(imageStatusRowsPerPageProvider.notifier).state = value;
        }
      },
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      columns: _createColumns(),
      source: _dataSource,
      loading: const Center(child: CircularProgressIndicator()),
      empty: const Center(child: Text('Tidak ada data ditemukan')),
    );
  }

  void _onSort(int columnIndex, bool ascending) {
    final Map<int, String> columnMapping = {
      0: 'id',
      1: 'type_engine',
      2: 'merk',
      3: 'type_chassis',
      4: 'jenis_kendaraan',
      5: 'varian_body',
      7: 'created_at',
      8: 'updated_at',
      9: 'deskripsi_optional',
    };

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });

    ref.read(imageStatusFilterProvider.notifier).update((state) {
      return {
        ...state,
        'sortBy': columnMapping[columnIndex] ?? 'id',
        'sortDirection': ascending ? 'asc' : 'desc',
      };
    });
  }

  List<DataColumn2> _createColumns() {
    return [
      // 1. ID Varian Body
      DataColumn2(label: const Text('ID'), fixedWidth: 40, onSort: _onSort),

      // 2. Type Engine
      DataColumn2(
        label: const Text('Type\nEngine'),
        fixedWidth: 62,
        onSort: _onSort,
      ),

      // 3. Merk
      DataColumn2(label: const Text('Merk'), fixedWidth: 90, onSort: _onSort),

      // 4. Type Chassis
      DataColumn2(
        label: const Text('Type Chassis'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),

      // 5. Jenis Kendaraan
      DataColumn2(
        label: const Text('Jenis Kendaraan'),
        fixedWidth: 115,
        onSort: _onSort,
      ),

      // 6. Varian Body
      DataColumn2(
        label: const Text('Varian Body'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),

      // 7. Gbr Utama (Action Column)
      const DataColumn2(
        label: Center(child: Text('Gambar Utama', textAlign: TextAlign.center)),
        fixedWidth: 123,
      ),
      DataColumn2(
        label: const Text('Created At'),
        fixedWidth: 99,
        onSort: _onSort,
      ),
      // 8. Updated At
      DataColumn2(
        label: const Text('Updated At'),
        fixedWidth: 99,
        onSort: _onSort,
      ),

      // 9. Gbr. Optional Paket
      DataColumn2(
        label: const Text('Gbr. Optional\nPaket'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),
    ];
  }
}

class _ImageStatusDataSourceWithContext extends ImageStatusDataSource {
  final BuildContext _context;
  final WidgetRef ref;

  _ImageStatusDataSourceWithContext(this.ref, this._context) : super(ref);

  @override
  void showPreviewDialog(GGambarUtama gambarUtama) {
    showDialog(
      context: _context,
      builder: (_) => GambarUtamaViewerDialog(gambarUtama: gambarUtama),
    );
  }

  // UBAH PARAMETER MENJADI 'ImageStatus'
  @override
  void confirmDeleteDialog(ImageStatus item) {
    final hasOptionalPaket = item.deskripsiOptional != null;
    final gambarUtama =
        item.gambarUtama!; // Pasti ada jika tombol delete muncul

    // Tentukan pesan teks dinamis
    final String contentText = hasOptionalPaket
        ? 'Apakah Anda yakin ingin menghapus Gambar Utama ini?\n\n'
              'PERINGATAN: File PDF Gambar Utama, Terurai, Kontruksi, dan Optional Paket akan dihapus permanen dari storage.'
        : 'Apakah Anda yakin ingin menghapus Gambar Utama ini?\n\n'
              'PERINGATAN: File PDF Gambar Utama, Terurai, dan Kontruksi akan dihapus permanen dari storage.';

    showDialog(
      context: _context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(contentText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(context).pop(); // Tutup Dialog
              try {
                // Panggil API Delete (menggunakan ID Gambar Utama)
                await ref
                    .read(masterDataRepositoryProvider)
                    .deleteGambarUtama(gambarUtama.id);

                refreshDatasource();

                if (_context.mounted) {
                  ScaffoldMessenger.of(_context).showSnackBar(
                    const SnackBar(
                      content: Text('Gambar Utama berhasil dihapus.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (_context.mounted) {
                  ScaffoldMessenger.of(_context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Hapus Permanen'),
          ),
        ],
      ),
    );
  }
}
