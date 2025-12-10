// File: lib/elements/home/widgets/gambar/gambar_kelistrikan_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/transaksi.dart';
import 'package:master_gambar/elements/home/providers/input_gambar_providers.dart';

class GambarKelistrikanSection extends ConsumerWidget {
  final Transaksi transaksi;
  final int pageNumber;
  final int totalHalaman;
  final VoidCallback onPreviewPressed;

  const GambarKelistrikanSection({
    super.key,
    required this.transaksi,
    required this.pageNumber,
    required this.totalHalaman,
    required this.onPreviewPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Baca info kelistrikan dari Provider (yang sudah diisi oleh Screen induk)
    final kelistrikanInfo = ref.watch(kelistrikanInfoProvider);

    // 2. Cek apakah ada data valid (ID Deskripsi dan ID File ada)
    final bool hasKelistrikan =
        kelistrikanInfo != null &&
        kelistrikanInfo['id'] != null &&
        kelistrikanInfo['file_id'] != null;

    final String deskripsi =
        kelistrikanInfo?['deskripsi'] ??
        'Deskripsi atau Gambar Kelistrikan tidak tersedia';

    final bool isPreviewEnabled =
        hasKelistrikan && ref.watch(pemeriksaIdProvider) != null;
    final isLoading = ref.watch(isProcessingProvider);

    return Row(
      children: [
        const SizedBox(width: 150, child: Text('Gambar Kelistrikan:')),
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            // Tampilkan deskripsi yang benar
            child: Text(
              deskripsi,
              style: TextStyle(
                fontStyle: hasKelistrikan ? FontStyle.normal : FontStyle.italic,
                color: hasKelistrikan ? Colors.black : Colors.grey.shade600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Tampilkan nomor halaman hanya jika data ada
        if (hasKelistrikan)
          SizedBox(
            width: 70,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.yellow.shade200,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey),
              ),
              child: Center(child: Text('$pageNumber/$totalHalaman')),
            ),
          ),
        const SizedBox(width: 10),
        // Tampilkan tombol preview
        SizedBox(
          width: 170,
          child: ElevatedButton(
            onPressed: isPreviewEnabled && !isLoading ? onPreviewPressed : null,
            child: const Text('Preview Gambar'),
          ),
        ),
      ],
    );
  }
}
