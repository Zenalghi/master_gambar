// File: lib/admin/master/widgets/image_status_datasource.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';

// Provider untuk data source tabel
final imageStatusSourceProvider = Provider.autoDispose<ImageStatusDataSource>(
  (ref) => ImageStatusDataSource(ref),
);

// Data source untuk AsyncPaginatedDataTable2
class ImageStatusDataSource extends AsyncDataTableSource {
  final Ref _ref;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  ImageStatusDataSource(this._ref) {
    // Dengarkan perubahan pada filter, lalu refresh tabel
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
          return DataRow(
            key: ValueKey(vb.id),
            cells: [
              DataCell(
                SelectableText(
                  vb.jenisKendaraan.typeChassis.merk.typeEngine.name,
                ),
              ),
              DataCell(SelectableText(vb.jenisKendaraan.typeChassis.merk.name)),
              DataCell(SelectableText(vb.jenisKendaraan.typeChassis.name)),
              DataCell(SelectableText(vb.jenisKendaraan.name)),
              DataCell(SelectableText(vb.name)),
              DataCell(
                Center(child: _buildStatusIcon(item.gambarUtama != null)),
              ),
              DataCell(
                SelectableText(
                  item.gambarUtama != null
                      ? dateFormat.format(item.gambarUtama!.updatedAt.toLocal())
                      : 'N/A',
                ),
              ),
              DataCell(
                Center(
                  child: _buildStatusIcon(item.latestGambarOptional != null),
                ),
              ),
              DataCell(
                SelectableText(
                  item.latestGambarOptional != null
                      ? dateFormat.format(
                          item.latestGambarOptional!.updatedAt.toLocal(),
                        )
                      : 'N/A',
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

  Widget _buildStatusIcon(bool hasImage) {
    return Icon(
      hasImage ? Icons.check_circle : Icons.cancel,
      color: hasImage ? Colors.green : Colors.red,
    );
  }
}
