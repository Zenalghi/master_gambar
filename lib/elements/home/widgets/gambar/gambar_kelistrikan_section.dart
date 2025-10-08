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
    // Awasi provider data yang baru
    final kelistrikanAsync = ref.watch(
      gambarKelistrikanDataProvider(transaksi.cTypeChassis.id),
    );

    return kelistrikanAsync.when(
      data: (kelistrikanItem) {
        final bool hasKelistrikan = kelistrikanItem != null;
        final bool isPreviewEnabled =
            hasKelistrikan && ref.watch(pemeriksaIdProvider) != null;
        final isLoading = ref.watch(isProcessingProvider);

        return Row(
          children: [
            const SizedBox(width: 150, child: Text('Gambar Kelistrikan:')),
            Expanded(
              flex: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                // Tampilkan deskripsi atau keterangan
                child: Text(
                  hasKelistrikan
                      ? kelistrikanItem.name
                      : 'Gambar Kelistrikan tidak tersedia',
                  style: TextStyle(
                    fontStyle: hasKelistrikan
                        ? FontStyle.normal
                        : FontStyle.italic,
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
            // Tampilkan tombol preview hanya jika data ada
            SizedBox(
              width: 170,
              child: ElevatedButton(
                onPressed: isPreviewEnabled && !isLoading
                    ? onPreviewPressed
                    : null,
                child: const Text('Preview Gambar'),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error memuat data kelistrikan: $err'),
    );
  }
}
