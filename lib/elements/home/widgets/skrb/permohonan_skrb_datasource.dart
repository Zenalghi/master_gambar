// File: lib/elements/home/widgets/skrb/permohonan_skrb_datasource.dart
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/data/models/skrb.dart';
import '../../providers/page_state_provider.dart';
import '../../providers/skrb_providers.dart';
import '../../repository/skrb_repository.dart';

class PermohonanSkrbDataSource extends DataTableSource {
  final List<Skrb> skrbList;
  final WidgetRef ref;
  final BuildContext context;

  PermohonanSkrbDataSource({
    required this.skrbList,
    required this.ref,
    required this.context,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= skrbList.length) return null;
    final skrb = skrbList[index];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isUnsavedDraft = skrb.fase == 1 || skrb.histories.isEmpty;

    return DataRow2.byIndex(
      index: index,
      cells: [
        DataCell(
          SelectableText(
            skrb.idSkrb,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataCell(SelectableText(skrb.transaksiId)),
        DataCell(SelectableText(skrb.customerName)),
        DataCell(SelectableText(skrb.typeEngine)),
        DataCell(SelectableText(skrb.merk)),
        DataCell(SelectableText(skrb.typeChassis)),
        DataCell(SelectableText(skrb.jenisKendaraan)),
        DataCell(SelectableText(skrb.jenisPengajuan)),
        DataCell(SelectableText(_formatDate(skrb.createdAt))),
        DataCell(SelectableText(_formatDate(skrb.updatedAt))),
        DataCell(
          _buildStatusTdpWidget(
            skrb.statusTdp,
            skrb.tdpMasaBerlaku,
            skrb.isTdpOutdated,
            colorScheme,
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tombol Edit hanya muncul jika sudah pernah disimpan / bukan draft awal
              if (!isUnsavedDraft) ...[
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange, size: 18),
                  tooltip: skrb.fase == 2
                      ? 'Buka ke Mode Edit'
                      : 'Lanjutkan Mode Edit', // (Fase 3)
                  onPressed: () async {
                    bool dialogShown = false;
                    try {
                      // Set ke fase 3 (Mode Edit) jika berada pada fase 2
                      if (skrb.fase == 2) {
                        dialogShown = true;
                        _showLoadingDialog(
                          'Harap tunggu sebentar...\nMemproses pembuatan dan penarikan ulang gambar & dokumen...',
                        );
                        await ref
                            .read(skrbRepositoryProvider)
                            .updatePhase(skrb.id, 3);
                        ref.invalidate(skrbListProvider);
                      }
                      ref.invalidate(skrbDetailProvider(skrb.id));
                      if (dialogShown && context.mounted) {
                        Navigator.of(context, rootNavigator: true).pop();
                      }
                      ref.read(pageStateProvider.notifier).state = PageState(
                        pageIndex: 3,
                        skrbId: skrb.id,
                      );
                    } catch (e) {
                      if (dialogShown && context.mounted) {
                        Navigator.of(context, rootNavigator: true).pop();
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(width: 4),
              ],
              // Tombol Navigasi -> Masuk ke Screen DETAIL SKRB
              IconButton(
                icon: isUnsavedDraft
                    ? const Icon(Icons.edit_note, color: Colors.teal, size: 18)
                    : (skrb.fase == 2
                          ? const Icon(
                              Icons.description_outlined,
                              color: Colors.blue,
                              size: 18,
                            )
                          : const Icon(
                              Icons.edit,
                              color: Colors.orange,
                              size: 18,
                            )),
                // Icon(
                //   Icons.arrow_forward_ios_rounded,
                //   color: isUnsavedDraft ? Colors.teal : Colors.blue,
                //   size: 16,
                // ),
                tooltip: isUnsavedDraft
                    ? 'Masuk & Lanjutkan Proses (Belum Disimpan)'
                    : (skrb.fase == 2
                          ? 'Lihat Detail SKRB'
                          : 'Masuk ke Detail (Mode Edit)'),
                onPressed: () {
                  ref.invalidate(skrbDetailProvider(skrb.id));
                  ref.read(pageStateProvider.notifier).state = PageState(
                    pageIndex: 3,
                    skrbId: skrb.id,
                  );
                },
              ),
              const SizedBox(width: 4),
              // Tombol Hapus Total SKRB
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                tooltip: 'Hapus Permohonan SKRB',
                onPressed: () => _confirmDelete(skrb),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(Skrb skrb) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Permohonan SKRB'),
        content: Text(
          'Apakah Anda yakin ingin menghapus permohonan SKRB dengan ID ${skrb.idSkrb} untuk Transaksi ${skrb.transaksiId}?\n\nSeluruh arsip file PDF dan folder di storage server akan dihapus secara permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(skrbRepositoryProvider).deleteSkrb(skrb.id);
                ref.invalidate(skrbListProvider);
                ref.invalidate(availableTransactionsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Permohonan SKRB berhasil dihapus total.',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text(
              'Hapus Total',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTdpWidget(
    String status,
    String? masaBerlakuStr,
    bool isOutdated,
    ColorScheme colorScheme,
  ) {
    String tglStr = '';
    if (masaBerlakuStr != null &&
        masaBerlakuStr.isNotEmpty &&
        masaBerlakuStr != '-') {
      try {
        final date = DateTime.parse(masaBerlakuStr);
        const bulan = [
          '',
          'Januari',
          'Februari',
          'Maret',
          'April',
          'Mei',
          'Juni',
          'Juli',
          'Agustus',
          'September',
          'Oktober',
          'November',
          'Desember',
        ];
        tglStr =
            '\nMasa Berlaku: ${date.day} ${bulan[date.month]} ${date.year}';
      } catch (_) {}
    }

    Color color;
    String tooltip;
    IconData icon;

    if (status.toLowerCase() == 'aktif' ||
        status.toLowerCase().contains('aktif')) {
      color = Colors.green.shade600;
      tooltip =
          'Aktif: Masa berlaku TDP masih aman (lebih dari 5 pekan).$tglStr';
      icon = Icons.check_circle;
    } else if (status.toLowerCase() == 'warning' ||
        status.toLowerCase().contains('warn')) {
      color = Colors.orange.shade800;
      tooltip =
          'WARNING: Masa berlaku TDP akan habis dalam 5 pekan atau kurang!$tglStr';
      icon = Icons.warning_amber;
    } else if (status.toLowerCase() == 'expired' ||
        status.toLowerCase().contains('exp')) {
      color = Colors.red.shade700;
      tooltip = 'Expired: Masa berlaku TDP sudah lewat / kadaluarsa!$tglStr';
      icon = Icons.cancel;
    } else if (status.toLowerCase().contains('diperbarui')) {
      color = Colors.blue.shade700;
      tooltip =
          'Diperbarui Admin: TDP telah diupdate oleh Admin pada Document Customer.$tglStr\nMohon edit dan simpan ulang SKRB ini jika ingin menggunakan file TDP terbaru.';
      icon = Icons.update;
    } else {
      color = colorScheme.onSurface;
      tooltip = 'Status: $status$tglStr';
      icon = Icons.help_outline;
    }

    if (isOutdated && !status.toLowerCase().contains('diperbarui')) {
      tooltip +=
          '\n\n💡 TIP: TDP sudah diupdate oleh admin di Document Customer.\nMohon update dan simpan ulang SKRB ini agar versi PDF tersinkronisasi.';
    }

    return Tooltip(
      message: tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.replaceAll('Diperbarui Admin', 'Diperbarui\nAdmin'),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          if (isOutdated && !status.toLowerCase().contains('diperbarui')) ...[
            const SizedBox(width: 3),
            Icon(
              Icons.change_circle_outlined,
              size: 14,
              color: Colors.blue.shade700,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      if (iso.isEmpty || iso == '-') return '-';
      final date = DateTime.parse(iso).toLocal();
      return DateFormat('yyyy.MM.dd HH:mm').format(date);
    } catch (_) {
      return iso;
    }
  }

  void _showLoadingDialog(String title) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => skrbList.length;
  @override
  int get selectedRowCount => 0;
}
