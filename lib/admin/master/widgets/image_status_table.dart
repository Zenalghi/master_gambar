// File: lib/admin/master/widgets/image_status_table.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/models/image_status.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:master_gambar/data/models/paginated_response.dart';
import 'package:intl/intl.dart';

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
        var dateFormat = DateFormat('dd.MM.yyyy HH:mm');
        return DataRow(
          key: ValueKey(vb.id),
          cells: [
            DataCell(Text(vb.jenisKendaraan.typeChassis.merk.typeEngine.name)),
            DataCell(Text(vb.jenisKendaraan.typeChassis.merk.name)),
            DataCell(Text(vb.jenisKendaraan.typeChassis.name)),
            DataCell(Text(vb.jenisKendaraan.name)),
            DataCell(Text(vb.name)),
            DataCell(Center(child: _buildStatusIcon(item.gambarUtama != null))),
            DataCell(
              Text(
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
              Text(
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
  }

  Widget _buildStatusIcon(bool hasImage) {
    return Icon(
      hasImage ? Icons.check_circle : Icons.cancel,
      color: hasImage ? Colors.green : Colors.red,
    );
  }
}

// Widget Tabel Utama
class ImageStatusTable extends ConsumerStatefulWidget {
  // Ubah menjadi stateful
  const ImageStatusTable({super.key});

  @override
  ConsumerState<ImageStatusTable> createState() => _ImageStatusTableState();
}

class _ImageStatusTableState extends ConsumerState<ImageStatusTable> {
  int _sortColumnIndex = 6;
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    final source = ref.watch(imageStatusSourceProvider);
    final rowsPerPage = ref.watch(merkRowsPerPageProvider);

    return AsyncPaginatedDataTable2(
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      rowsPerPage: rowsPerPage,
      columns: _createColumns(),
      source: source,
    );
  }

  // Method baru untuk handle sort
  void _onSort(int columnIndex, bool ascending) {
    final Map<int, String> columnMapping = {
      0: 'type_engine', 1: 'merk', 2: 'type_chassis',
      3: 'jenis_kendaraan', 4: 'varian_body',
      // Kita tidak bisa sort berdasarkan status, tapi bisa berdasarkan tanggal
      6: 'updated_at', // Asumsi untuk Gbr. Utama
      8: 'updated_at', // Asumsi untuk Gbr. Optional
    };

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      ref.read(imageStatusFilterProvider.notifier).update((state) {
        return {
          ...state,
          'sortBy': columnMapping[columnIndex] ?? 'updated_at',
          'sortDirection': ascending ? 'asc' : 'desc',
        };
      });
    });
  }

  // Buat kolom baru
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
      DataColumn2(
        label: const Text('Updated At'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      const DataColumn2(
        label: Center(child: Text('Gbr. Optional')),
        fixedWidth: 100,
      ),
      DataColumn2(
        label: const Text('Updated At'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
    ];
  }
}
