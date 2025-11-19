// File: lib/admin/master/widgets/master_data_datasource.dart
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/models/master_data.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'edit_master_data_dialog.dart'; // Kita buat setelah ini
import 'add_gambar_kelistrikan_dialog.dart'; // Dialog khusus kelistrikan

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
              // Icon Kelistrikan
              DataCell(
                Center(
                  child: item.kelistrikanId != null
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.blue,
                          ),
                          tooltip: 'Tambah Gambar Kelistrikan',
                          onPressed: () => _showAddKelistrikanDialog(item),
                        ),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
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

  void _showAddKelistrikanDialog(MasterData item) {
    // Implementasi dialog tambah kelistrikan (mengirim 3 ID: Engine, Merk, Chassis)
    // ...
  }

  void _showDeleteDialog(MasterData item) {
    // Implementasi konfirmasi hapus
    // ...
  }
}
