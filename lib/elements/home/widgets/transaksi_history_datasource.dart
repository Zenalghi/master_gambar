// File: lib/elements/home/widgets/transaksi_history_datasource.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/app/core/providers.dart';
import 'package:master_gambar/elements/home/providers/page_state_provider.dart';
import 'package:master_gambar/elements/home/providers/transaksi_providers.dart';
import 'package:master_gambar/elements/home/repository/options_repository.dart';
import '../../../data/models/transaksi.dart';

final transaksiDataSourceProvider =
    Provider.family<TransaksiDataSource, void Function(Transaksi)>(
      (ref, onEdit) => TransaksiDataSource(ref, onEdit: onEdit),
    );

class TransaksiDataSource extends AsyncDataTableSource {
  final Ref _ref;
  final Function(Transaksi trx) onEdit;
  final DateFormat dateFormat = DateFormat('yyyy.MM.dd HH:mm');

  TransaksiDataSource(this._ref, {required this.onEdit}) {
    // Dengarkan perubahan pada filter, lalu refresh tabel
    _ref.listen(transaksiFilterProvider, (_, __) {
      refreshDatasource();
    });
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final filters = _ref.read(transaksiFilterProvider);
    final authService = _ref.read(authServiceProvider);
    final currentUserId = _ref.read(currentUserIdProvider);

    try {
      final response = await _ref
          .read(transaksiRepositoryProvider)
          .getTransaksiHistory(
            perPage: count,
            page: (startIndex ~/ count) + 1,
            search: filters['search']!,
            sortBy: filters['sortBy']!,
            sortDirection: filters['sortDirection']!,
          );

      return AsyncRowsResponse(
        response.total,
        response.data.map((trx) {
          final canEdit =
              authService.canViewAdminTabs() || trx.user.id == currentUserId;
          return DataRow(
            key: ValueKey(trx.id),
            cells: [
              DataCell(SelectableText(trx.id)),
              DataCell(SelectableText(trx.customer.namaPt)),
              DataCell(SelectableText(trx.aTypeEngine.typeEngine)),
              DataCell(SelectableText(trx.bMerk.merk)),
              DataCell(SelectableText(trx.cTypeChassis.typeChassis)),
              DataCell(SelectableText(trx.dJenisKendaraan.jenisKendaraan)),
              DataCell(SelectableText(trx.fPengajuan.jenisPengajuan)),
              DataCell(SelectableText(trx.user.name)),
              DataCell(
                SelectableText(dateFormat.format(trx.createdAt.toLocal())),
              ),
              DataCell(
                SelectableText(dateFormat.format(trx.updatedAt.toLocal())),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: canEdit ? Colors.orange.shade700 : Colors.grey,
                      ),
                      tooltip: canEdit ? 'Edit' : 'Anda tidak punya akses',
                      onPressed: canEdit ? () => onEdit(trx) : null,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.open_in_new,
                        color: Colors.blue.shade700,
                      ),
                      tooltip: 'Open',
                      onPressed: () {
                        _ref.read(pageStateProvider.notifier).state = PageState(
                          pageIndex: 1,
                          data: trx,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      );
    } catch (e) {
      // Handle error
      return AsyncRowsResponse(0, []);
    }
  }
}
