// File: lib/admin/master/widgets/master_data_datasource.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/models/master_data.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:master_gambar/data/models/option_item.dart';
import 'edit_master_data_dialog.dart';

class MasterDataDataSource extends AsyncDataTableSource {
  final WidgetRef _ref;
  final BuildContext context;

  MasterDataDataSource(this._ref, this.context) {
    _ref.listen(masterDataFilterProvider, (_, __) => refreshDatasource());
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final filters = _ref.read(masterDataFilterProvider);
    try {
      final response = await _ref
          .read(masterDataRepositoryProvider)
          .getMasterDataPaginated(
            perPage: count,
            page: (startIndex ~/ count) + 1,
            search: filters['search']!,
            sortBy: filters['sortBy']!,
            sortDirection: filters['sortDirection']!,
          );

      return AsyncRowsResponse(
        response.total,
        response.data.map((item) {
          return DataRow(
            key: ValueKey(item.id),
            cells: [
              DataCell(SelectableText(item.typeEngine.name)),
              DataCell(SelectableText(item.merk.name)),
              DataCell(SelectableText(item.typeChassis.name)),
              DataCell(SelectableText(item.jenisKendaraan.name)),
              // Kolom Kelistrikan
              DataCell(
                Center(
                  child: item.kelistrikanId != null
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.blue,
                          ),
                          tooltip: 'Tambah Gambar Kelistrikan (Auto-fill)',
                          onPressed: () => _navigateToKelistrikan(item),
                        ),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- TOMBOL COPY (BARU) ---
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.orange),
                      tooltip: 'Copy Data ke Form',
                      onPressed: () {
                        // Kirim data item ini ke provider agar form di atas menangkapnya
                        _ref.read(masterDataToCopyProvider.notifier).state =
                            item;
                      },
                    ),
                    // --------------------------
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => EditMasterDataDialog(masterData: item),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteDialog(item),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      );
    } catch (e) {
      return AsyncRowsResponse(0, []);
    }
  }

  void _navigateToKelistrikan(MasterData item) {
    final initialData = {
      'typeEngine': OptionItem(
        id: item.typeEngine.id,
        name: item.typeEngine.name,
      ),
      'merk': OptionItem(id: item.merk.id, name: item.merk.name),
      'typeChassis': OptionItem(
        id: item.typeChassis.id,
        name: item.typeChassis.name,
      ),
    };
    _ref.read(initialKelistrikanDataProvider.notifier).state = initialData;
    _ref.read(adminSidebarIndexProvider.notifier).state =
        10; // Index menu kelistrikan
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data disalin! Silakan lengkapi form.')),
    );
  }

  // --- IMPLEMENTASI DELETE DIALOG (BARU) ---
  void _showDeleteDialog(MasterData item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Yakin ingin menghapus Master Data ini?\n\nID: ${item.id}\nKombinasi: ${item.typeEngine.name} - ${item.merk.name} - ...',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              try {
                await _ref
                    .read(masterDataRepositoryProvider)
                    .deleteMasterData(id: item.id);

                if (context.mounted) {
                  Navigator.of(context).pop(); // Tutup dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  refreshDatasource(); // Refresh tabel
                }
              } on DioException catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  // Menampilkan pesan error dari backend (misal: validasi terpakai di varian body)
                  final message =
                      e.response?.data['message'] ??
                      e.response?.data['errors']?['general']?[0] ??
                      'Gagal menghapus data';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
