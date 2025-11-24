// File: lib/admin/master/widgets/image_status_datasource.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/master/models/g_gambar_utama.dart';
import 'package:master_gambar/admin/master/models/image_status.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:master_gambar/data/models/option_item.dart';

// Hapus provider global karena diinstansiasi di UI
// final imageStatusSourceProvider ...

class ImageStatusDataSource extends AsyncDataTableSource {
  final WidgetRef _ref;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  ImageStatusDataSource(this._ref);
  // ImageStatusDataSource(this._ref) {
  //   _ref.listen(imageStatusFilterProvider, (_, __) => refreshDatasource());
  // }

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
          final optionalDesc = item.deskripsiOptional ?? 'N/A';
          final bool hasImage = item.gambarUtama != null;

          return DataRow(
            key: ValueKey(vb.id),
            cells: [
              // 1. ID Varian Body
              DataCell(SelectableText(vb.id.toString())),

              // 2. Type Engine
              DataCell(SelectableText(masterData.typeEngine.name)),

              // 3. Merk
              DataCell(SelectableText(masterData.merk.name)),

              // 4. Type Chassis
              DataCell(SelectableText(masterData.typeChassis.name)),

              // 5. Jenis Kendaraan
              DataCell(SelectableText(masterData.jenisKendaraan.name)),

              // 6. Varian Body
              DataCell(SelectableText(vb.name)),

              // 7. Gbr Utama (Action Column)
              DataCell(
                Center(
                  child: hasImage
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tombol PREVIEW (Mata)
                            IconButton(
                              icon: Icon(
                                Icons.visibility,
                                color: Colors.blue.shade700,
                              ),
                              tooltip: 'Preview Semua Gambar',
                              onPressed: () =>
                                  showPreviewDialog(item.gambarUtama!),
                            ),
                            // Tombol EDIT (Pensil)
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.orange,
                              ),
                              tooltip: 'Edit / Ganti Gambar',
                              onPressed: () => _navigateToEdit(item),
                            ),
                          ],
                        )
                      : ElevatedButton.icon(
                          // Tombol ADD (Upload)
                          onPressed: () => _navigateToAdd(item),
                          icon: const Icon(Icons.upload_file, size: 16),
                          label: const Text('Upload'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Tombol hijau
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                ),
              ),

              // 8. Updated At
              DataCell(
                SelectableText(
                  item.gambarUtamaUpdatedAt != null
                      ? dateFormat.format(item.gambarUtamaUpdatedAt!.toLocal())
                      : 'Belum ada',
                ),
              ),

              // 9. Gbr Optional (Deskripsi)
              DataCell(
                optionalDesc != 'N/A'
                    ? SelectableText(optionalDesc)
                    : const Center(
                        child: Text('Belum ada'),
                      ), // Tanda strip jika kosong
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

  // Method untuk di-override di Table Widget
  void showPreviewDialog(GGambarUtama gambarUtama) {}

  // --- LOGIKA TOMBOL ADD (UPLOAD BARU) ---
  void _navigateToAdd(ImageStatus item) {
    final vb = item.varianBody;
    final md = vb.masterData;

    // 1. Set Data untuk Dropdown
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

    // 2. Pastikan Mode Edit MATI
    _ref.read(mguEditingGambarProvider.notifier).state = null;

    // 3. Navigasi
    _ref.read(adminSidebarIndexProvider.notifier).state = 8;
  }

  // --- LOGIKA TOMBOL EDIT ---
  void _navigateToEdit(ImageStatus item) {
    // 1. Set Data untuk Dropdown (sama seperti add)
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

    // 2. Set Mode Edit AKTIF & Isi Datanya
    // Screen target akan membaca ini dan mengisi form file
    _ref.read(mguEditingGambarProvider.notifier).state = item.gambarUtama;

    // 3. Navigasi
    _ref.read(adminSidebarIndexProvider.notifier).state = 8;
  }
}
