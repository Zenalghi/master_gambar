// File: lib/elements/home/widgets/detail_skrb/detail_skrb_tdp_status.dart
import 'package:flutter/material.dart';
import 'package:master_gambar/data/models/skrb.dart';
import 'doc_item.dart';

class DetailSkrbTdpStatus extends StatelessWidget {
  final Skrb skrb;
  final DocItem item;

  const DetailSkrbTdpStatus({
    super.key,
    required this.skrb,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!item.hasFile || skrb.statusTdp == 'Kosong' || skrb.statusTdp == '-') {
      return Row(
        children: [
          const Icon(
            Icons.radio_button_unchecked,
            size: 16,
            color: Colors.grey,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              item.statusText,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    final status = skrb.statusTdp;
    final masaBerlakuStr = skrb.tdpMasaBerlaku;
    final isOutdated = skrb.isTdpOutdated;

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
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              item.statusText,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isOutdated && !status.toLowerCase().contains('diperbarui')) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.change_circle_outlined,
              size: 16,
              color: Colors.blue.shade700,
            ),
          ],
        ],
      ),
    );
  }
}
