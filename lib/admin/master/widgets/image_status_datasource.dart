// File: lib/admin/master/widgets/image_status_datasource.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/master/models/g_gambar_utama.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:master_gambar/data/models/option_item.dart';
// Import dialogs (pastikan pathnya benar)
// import 'gambar_utama_viewer_dialog.dart';

// Hapus provider global jika ada, kita akan instansiasi di UI

class ImageStatusDataSource extends AsyncDataTableSource {
  // UBAH TIPE MENJADI WidgetRef AGAR COCOK DENGAN UI
  final WidgetRef _ref;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  ImageStatusDataSource(this._ref) {
    _ref.listen(imageStatusFilterProvider, (_, __) => refreshDatasource());
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final filters = _ref.read(imageStatusFilterProvider);
    try {
      final response = await _ref
          .read(masterDataRepositoryProvider)
          .getImageStatus(
            perPage: count,
            page: (startIndex ~/ count) + 1,
            search: filters['search'] as String,
            sortBy: filters['sortBy'] as String,
            sortDirection: filters['sortDirection'] as String,
          );

      return AsyncRowsResponse(
        response.total,
        response.data.map((item) {
          final vb = item.varianBody;
          final masterData = vb.masterData;

          // Logic deskripsi optional
          final optionalDesc = item.deskripsiOptional ?? 'N/A';

          return DataRow(
            key: ValueKey(vb.id),
            cells: [
              DataCell(SelectableText(masterData.typeEngine.name)),
              DataCell(SelectableText(masterData.merk.name)),
              DataCell(SelectableText(masterData.typeChassis.name)),
              DataCell(SelectableText(masterData.jenisKendaraan.name)),
              DataCell(SelectableText(vb.name)),

              // KOLOM GBR. UTAMA (VIEW BUTTON)
              DataCell(
                Center(
                  child: item.gambarUtama != null
                      ? IconButton(
                          icon: Icon(
                            Icons.visibility,
                            color: Colors.blue.shade700,
                          ),
                          tooltip: 'Lihat Gambar Utama',
                          // Panggil method yang akan di-override di file Table
                          onPressed: () => showPreviewDialog(item.gambarUtama!),
                        )
                      : const Icon(Icons.cancel, color: Colors.red),
                ),
              ),

              DataCell(
                optionalDesc != 'N/A'
                    ? SelectableText(optionalDesc)
                    : const Center(
                        child: Icon(Icons.cancel, color: Colors.red),
                      ),
              ),

              DataCell(
                SelectableText(
                  item.gambarUtamaUpdatedAt != null
                      ? dateFormat.format(item.gambarUtamaUpdatedAt!.toLocal())
                      : '-',
                ),
              ),

              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy_all, color: Colors.orange),
                      tooltip: 'Copy Data & Kelola Gambar',
                      onPressed: () => _navigateToManageGambar(item),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      );
    } catch (e) {
      debugPrint('Error fetching Image Status: $e');
      return AsyncRowsResponse(0, []);
    }
  }

  // Method ini akan di-override oleh class turunan di file Table
  // agar bisa mengakses Context untuk ShowDialog
  void showPreviewDialog(GGambarUtama gambarUtama) {
    // Default implementation (kosong), akan ditimpa
  }

  void _navigateToManageGambar(dynamic item) {
    final vb = item.varianBody;
    final md = vb.masterData;

    final initialData = {
      'typeEngine': OptionItem(id: md.typeEngine.id, name: md.typeEngine.name),
      'merk': OptionItem(id: md.merk.id, name: md.merk.name),
      'typeChassis': OptionItem(
        id: md.typeChassis.id,
        name: md.typeChassis.name,
      ),
      'jenisKendaraan': OptionItem(
        id: md.jenisKendaraan.id,
        name: md.jenisKendaraan.name,
      ),
      'varianBody': OptionItem(id: vb.id, name: vb.name),
    };

    _ref.read(initialGambarUtamaDataProvider.notifier).state = initialData;
    _ref.read(adminSidebarIndexProvider.notifier).state = 8;
  }
}
