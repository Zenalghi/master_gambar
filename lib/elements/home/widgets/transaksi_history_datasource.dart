// File: lib/elements/home/widgets/transaksi_history_datasource.dart

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/app/core/providers.dart';
import 'package:master_gambar/elements/auth/auth_service.dart'; // Pastikan import ini benar
import 'package:master_gambar/elements/home/providers/page_state_provider.dart';
import 'package:master_gambar/elements/home/providers/transaksi_providers.dart';
import 'package:master_gambar/elements/home/repository/options_repository.dart';
import '../../../data/models/transaksi.dart';
import 'edit_transaksi_dialog.dart';

class TransaksiDataSource extends AsyncDataTableSource {
  final WidgetRef _ref;
  final BuildContext context;
  final DateFormat dateFormat = DateFormat('yyyy.MM.dd HH:mm');

  // Constructor sederhana
  TransaksiDataSource(this._ref, this.context);

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    // 1. Ambil state filter terbaru
    final filters = _ref.read(transaksiFilterProvider);
    final authService = _ref.read(authServiceProvider);
    final currentUserId = _ref.read(currentUserIdProvider);

    try {
      // 2. Panggil API dengan parameter lengkap
      final response = await _ref
          .read(transaksiRepositoryProvider)
          .getTransaksiHistory(
            perPage: count,
            page: (startIndex ~/ count) + 1,
            search: filters['search'] as String,
            sortBy: filters['sortBy'] as String,
            sortDirection: filters['sortDirection'] as String,
            // Kirim seluruh map filters sebagai advancedFilters
            advancedFilters: filters,
          );

      // 3. Mapping data ke DataRow
      return AsyncRowsResponse(
        response.total,
        response.data.map((trx) {
          // Logika akses edit
          final canEdit =
              authService.canViewAdminTabs() || (trx.user.id == currentUserId);

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
                    // Tombol Edit
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: canEdit ? Colors.orange.shade700 : Colors.grey,
                      ),
                      tooltip: canEdit ? 'Edit' : 'Anda tidak punya akses',
                      onPressed: canEdit ? () => _showEditDialog(trx) : null,
                    ),
                    // Tombol Open (Pindah Halaman)
                    IconButton(
                      icon: const Icon(Icons.open_in_new, color: Colors.blue),
                      tooltip: 'Buka Detail / Input Gambar',
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
