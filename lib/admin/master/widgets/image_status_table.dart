// File: lib/admin/master/widgets/image_status_table.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/models/image_status.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:master_gambar/data/models/paginated_response.dart';

// Provider untuk data source tabel
final imageStatusSourceProvider = Provider<ImageStatusDataSource>(
  (ref) => ImageStatusDataSource(ref),
);

// Data source untuk AsyncPaginatedDataTable2
class ImageStatusDataSource extends AsyncDataTableSource {
  final Ref _ref;
  PaginatedResponse<ImageStatus>? _lastData;

  ImageStatusDataSource(this._ref) {
    _ref.listen(imageStatusFilterProvider, (_, __) => refreshDatasource());
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final filters = _ref.read(imageStatusFilterProvider);

    final response = await _ref
        .read(masterDataRepositoryProvider)
        .getImageStatus(
          perPage: count,
          page: (startIndex ~/ count) + 1,
          search: filters['search']!,
          sortBy: filters['sortBy']!,
          sortDirection: filters['sortDirection']!,
        );

    _lastData = response;

    return AsyncRowsResponse(
      response.total,
      response.data.map((item) {
        final vb = item.varianBody;
        return DataRow(
          key: ValueKey(vb.id),
          cells: [
            DataCell(Text(vb.jenisKendaraan.typeChassis.merk.typeEngine.name)),
            DataCell(Text(vb.jenisKendaraan.typeChassis.merk.name)),
            DataCell(Text(vb.jenisKendaraan.typeChassis.name)),
            DataCell(Text(vb.jenisKendaraan.name)),
            DataCell(Text(vb.name)),
            DataCell(Center(child: _buildStatusIcon(item.hasGambarUtama))),
            DataCell(Center(child: _buildStatusIcon(item.hasGambarOptional))),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStatusIcon(bool hasImage) {
    return Icon(
      hasImage ? Icons.check_circle : Icons.cancel,
      color: hasImage ? Colors.green : Colors.red,
    );
  }
}

// Widget Tabel Utama
class ImageStatusTable extends ConsumerWidget {
  const ImageStatusTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final source = ref.watch(imageStatusSourceProvider);
    final rowsPerPage = ref.watch(
      merkRowsPerPageProvider,
    ); // Bisa pakai provider yg ada

    return AsyncPaginatedDataTable2(
      rowsPerPage: rowsPerPage,
      source: source,
      columns: const [
        DataColumn2(label: Text('Type Engine'), size: ColumnSize.S),
        DataColumn2(label: Text('Merk'), size: ColumnSize.S),
        DataColumn2(label: Text('Type Chassis'), size: ColumnSize.M),
        DataColumn2(label: Text('Jenis Kendaraan'), size: ColumnSize.M),
        DataColumn2(label: Text('Varian Body'), size: ColumnSize.M),
        DataColumn2(label: Center(child: Text('Gbr. Utama')), fixedWidth: 150),
        DataColumn2(
          label: Center(child: Text('Gbr. Optional')),
          fixedWidth: 150,
        ),
      ],
    );
  }
}
