// File: lib/admin/master/widgets/master_data_datasource.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Import intl
import 'package:master_gambar/admin/master/models/master_data.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:master_gambar/data/models/option_item.dart';
import 'edit_master_data_dialog.dart';

class MasterDataDataSource extends AsyncDataTableSource {
  final WidgetRef _ref;
  final BuildContext context;
  final DateFormat dateFormat = DateFormat(
    'yyyy-MM-dd HH:mm',
  ); // Formatter tanggal

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
              // --- 1. KOLOM ID ---
              DataCell(SelectableText(item.id.toString())),

              // Kolom Data
              DataCell(SelectableText(item.typeEngine.name)),
              DataCell(SelectableText(item.merk.name)),
              DataCell(SelectableText(item.typeChassis.name)),
              DataCell(SelectableText(item.jenisKendaraan.name)),

              // --- 2. KOLOM CREATED AT ---
              DataCell(
                SelectableText(dateFormat.format(item.createdAt.toLocal())),
              ), // Asumsi model punya createdAt
              // --- 3. KOLOM UPDATED AT ---
              DataCell(
                SelectableText(dateFormat.format(item.updatedAt.toLocal())),
              ), // Asumsi model punya updatedAt
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

              // Kolom Options
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.orange),
                      tooltip: 'Copy Data ke Form',
                      onPressed: () {
                        _ref.read(masterDataToCopyProvider.notifier).state =
                            item;
                      },
                    ),
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
    _ref.read(adminSidebarIndexProvider.notifier).state = 10;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data disalin! Silakan lengkapi form kelistrikan.'),
      ),
    );
  }

  void _showDeleteDialog(MasterData item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Yakin ingin menghapus Master Data ini?\n\n'
          'ID: ${item.id}\n'
          'Kombinasi: ${item.typeEngine.name} - ${item.merk.name} - ...',
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

                refreshDatasource();

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Data berhasil dihapus'),
                      backgroundColor: Colors.orange[400],
                    ),
                  );
                }
              } on DioException catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();

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
