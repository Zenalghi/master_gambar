// File: lib/admin/master/widgets/master_data_datasource.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/master/models/master_data.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:master_gambar/data/models/option_item.dart';
import 'edit_master_data_dialog.dart';
import 'kelistrikan_deskripsi_dialog.dart';

class MasterDataDataSource extends AsyncDataTableSource {
  final WidgetRef _ref;
  final BuildContext context;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  MasterDataDataSource(this._ref, this.context);

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
              DataCell(SelectableText(item.id.toString())),
              DataCell(SelectableText(item.typeEngine.name)),
              DataCell(SelectableText(item.merk.name)),
              DataCell(SelectableText(item.typeChassis.name)),
              DataCell(SelectableText(item.jenisKendaraan.name)),
              DataCell(
                SelectableText(dateFormat.format(item.createdAt.toLocal())),
              ),
              DataCell(
                SelectableText(dateFormat.format(item.updatedAt.toLocal())),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.copy,
                        size: 16,
                        color: Colors.lightBlueAccent,
                      ),
                      tooltip: 'Copy Data',
                      onPressed: () {
                        _ref.read(masterDataToCopyProvider.notifier).state =
                            item;
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.orange,
                      ),
                      tooltip: 'Edit Master Data',
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => EditMasterDataDialog(masterData: item),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        size: 16,
                        color: Colors.red,
                      ),
                      tooltip: 'Hapus Master Data',
                      onPressed: () => _showDeleteDialog(item),
                    ),
                  ],
                ),
              ),
              DataCell(_buildKelistrikanCell(item)),
            ],
          );
        }).toList(),
      );
    } catch (e) {
      debugPrint('Error MasterData: $e');
      return AsyncRowsResponse(0, []);
    }
  }

  Widget _buildKelistrikanCell(MasterData item) {
    if (item.kelistrikanId != null) {
      return Row(
        children: [
          IconButton(
            icon: const Icon(Icons.check_circle, size: 16, color: Colors.green),
            tooltip: 'Lengkap. Klik untuk Edit Deskripsi.',
            onPressed: () => _showDeskripsiDialog(item),
          ),
          Expanded(
            child: Text(
              item.kelistrikanDeskripsi ?? '',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      );
    } else if (item.fileKelistrikanId != null) {
      return Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.warning_amber_rounded,
              size: 16,
              color: Colors.orange,
            ),
            tooltip: 'File PDF tersedia. Klik untuk isi deskripsi.',
            onPressed: () => _showDeskripsiDialog(item),
          ),
          const Expanded(
            child: Text(
              "Set Deskripsi",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: IconButton(
          icon: const Icon(
            Icons.add_circle_outline,
            size: 16,
            color: Colors.red,
          ),
          tooltip: 'File PDF belum ada. Klik untuk upload.',
          onPressed: () => _navigateToGudangFile(item),
        ),
      );
    }
  }

  void _showDeskripsiDialog(MasterData item) {
    showDialog(
      context: context,
      builder: (_) => KelistrikanDeskripsiDialog(masterData: item),
    );
  }

  void _navigateToGudangFile(MasterData item) {
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
      const SnackBar(content: Text('Silakan upload file untuk data ini.')),
    );
  }

  void _showDeleteDialog(MasterData item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Hapus Master Data #${item.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // 1. Panggil API Delete
                await _ref
                    .read(masterDataRepositoryProvider)
                    .deleteMasterData(id: item.id);

                // 2. TUTUP DIALOG DULU (PENTING!)
                // Agar fokus UI lepas dari tombol delete dan overlay hilang
                if (context.mounted) {
                  Navigator.pop(context);
                }

                // 3. BARU REFRESH DATA SETELAHNYA
                // Gunakan Future.microtask atau delayed agar aman dari error layout
                Future.delayed(Duration.zero, () {
                  refreshDatasource();
                });

                // Tampilkan snackbar sukses (opsional)
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // Jika error, jangan tutup dialog, tapi kasih tahu user
                if (context.mounted) {
                  Navigator.pop(
                    context,
                  ); // Tutup dialog jika error parah, atau biarkan terbuka
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error menghapus data: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
