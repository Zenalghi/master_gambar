import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/app/core/providers.dart';
import 'package:master_gambar/elements/home/providers/page_state_provider.dart';
import 'package:master_gambar/elements/home/providers/transaksi_providers.dart';
import '../../../data/models/transaksi.dart';
import '../repository/options_repository.dart';
import 'edit_transaksi_dialog.dart';

class TransaksiDataSource extends AsyncDataTableSource {
  final WidgetRef _ref;
  final BuildContext context;
  final DateFormat dateFormat = DateFormat('yyyy.MM.dd HH:mm');

  TransaksiDataSource(this._ref, this.context);

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
            search: filters['search'] as String,
            sortBy: filters['sortBy'] as String,
            sortDirection: filters['sortDirection'] as String,
            advancedFilters: filters,
          );

      return AsyncRowsResponse(
        response.total,
        response.data.map((trx) {
          final canEdit =
              authService.canViewAdminTabs() || (trx.user.id == currentUserId);

          // Cek apakah ada draft tersimpan
          final bool hasDraft = trx.detail != null;

          return DataRow(
            key: ValueKey(trx.id),
            cells: [
              // 0. ID
              DataCell(SelectableText(trx.id.toString())),
              // 1. Customer
              DataCell(SelectableText(trx.customer.namaPt)),
              // 2. Engine
              DataCell(SelectableText(trx.aTypeEngine.typeEngine)),
              // 3. Merk
              DataCell(SelectableText(trx.bMerk.merk)),
              // 4. Chassis
              DataCell(SelectableText(trx.cTypeChassis.typeChassis)),
              // 5. Jenis Kendaraan
              DataCell(SelectableText(trx.dJenisKendaraan.jenisKendaraan)),
              // 6. Jenis Pengajuan
              DataCell(SelectableText(trx.fPengajuan.jenisPengajuan)),

              // 7. Judul Gambar (Gabungan dari detail)
              DataCell(
                SelectableText(trx.judulGambarString ?? '--judul offline--'),
              ),

              // 8. User
              DataCell(SelectableText(trx.user.name)),

              // 9. Created At
              DataCell(
                SelectableText(dateFormat.format(trx.createdAt.toLocal())),
              ),

              // 10. Updated At
              DataCell(
                SelectableText(dateFormat.format(trx.updatedAt.toLocal())),
              ),

              // Options
              DataCell(
                Row(
                  // mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: 15,
                        color: canEdit ? Colors.orange.shade700 : Colors.grey,
                      ),
                      tooltip: canEdit
                          ? 'Edit Data Transaksi'
                          : 'Anda tidak punya akses',
                      onPressed: canEdit ? () => _showEditDialog(trx) : null,
                    ),

                    // Tombol Proses / Lanjut Draft
                    IconButton(
                      icon: Icon(
                        // Ganti Icon jika ada Draft
                        hasDraft ? Icons.edit_document : Icons.open_in_new,
                        size: 15,
                        // Ganti Warna jika ada Draft
                        color: hasDraft ? Colors.lightBlueAccent : Colors.blue,
                      ),
                      tooltip: hasDraft
                          ? 'Detail Transaksi'
                          : 'Proses Transaksi Baru',
                      onPressed: () {
                        // Buka Tab Input Gambar (Index 1) dengan membawa data transaksi
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
      debugPrint('Error fetching Transaksi: $e');
      return AsyncRowsResponse(0, []);
    }
  }

  void _showEditDialog(Transaksi trx) {
    showDialog(
      context: context,
      builder: (_) => EditTransaksiDialog(transaksi: trx),
    );
  }
}
