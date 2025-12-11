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
    final kelistrikanInfo = ref.watch(kelistrikanInfoProvider);

    // 1. Baca status loading
    final bool isLoadingData = ref.watch(isLoadingKelistrikanProvider);

    final String displayText =
        kelistrikanInfo?['display_text'] ?? 'Memuat data kelistrikan...';
    final String statusCode = kelistrikanInfo?['status_code'] ?? 'loading';

    // Logika ready (hanya jika tidak loading dan status code ready)
    final bool isReady = !isLoadingData && statusCode == 'ready';
    final bool isPreviewEnabled =
        isReady && ref.watch(pemeriksaIdProvider) != null;
    final bool isProcessing = ref.watch(isProcessingProvider);

    Color bgColor;
    Color textColor;

    if (isReady) {
      bgColor = Colors.grey.shade200;
      textColor = Colors.black;
    } else {
      // Jika loading, pakai warna netral, jika error pakai merah
      bgColor = isLoadingData ? Colors.grey.shade100 : Colors.red.shade50;
      textColor = isLoadingData ? Colors.grey : Colors.red.shade900;
    }

    return Row(
      children: [
        const SizedBox(width: 150, child: Text('Gambar Kelistrikan:')),

        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            height: 48, // Tetapkan tinggi agar loader rapi
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(4),
              border: isReady || isLoadingData
                  ? null
                  : Border.all(color: Colors.red.shade200),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              // 2. Tampilkan Loader atau Teks
              child: isLoadingData
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Text(
                      displayText,
                      style: TextStyle(
                        fontStyle: isReady
                            ? FontStyle.normal
                            : FontStyle.italic,
                        color: textColor,
                        fontWeight: isReady
                            ? FontWeight.normal
                            : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Indikator Halaman
        if (isReady)
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
          )
        else
          const SizedBox(width: 70),

        const SizedBox(width: 10),

        // Tombol Preview
        SizedBox(
          width: 170,
          child: ElevatedButton(
            onPressed: isPreviewEnabled && !isProcessing
                ? onPreviewPressed
                : null,
            child: const Text('Preview Gambar'),
          ),
        ),
      ],
    );
  }
}
