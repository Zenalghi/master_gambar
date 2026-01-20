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
    final isLoadingData = ref.watch(isLoadingKelistrikanProvider);
    final selectedId = ref.watch(
      selectedKelistrikanIdProvider,
    ); // ID Pilihan User

    final String statusCode = kelistrikanInfo?['status_code'] ?? 'loading';
    final String displayText = kelistrikanInfo?['display_text'] ?? 'Memuat...';

    // Ambil list options (jika ada)
    final List<dynamic> options = kelistrikanInfo?['options'] ?? [];

    final bool isReady =
        !isLoadingData &&
        (statusCode == 'ready' || statusCode == 'multiple_options');
    final bool isPreviewEnabled =
        isReady && selectedId != null && ref.watch(pemeriksaIdProvider) != null;
    final bool isProcessing = ref.watch(isProcessingProvider);
    final bool isEditMode = ref.watch(isEditModeProvider); // Cek mode edit

    // Container Style
    final bgColor = isReady
        ? Colors.grey.shade200
        : (isLoadingData ? Colors.grey.shade100 : Colors.red.shade50);

    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Gambar Kelistrikan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align top agar rapi jika list panjang
          children: [
            const SizedBox(
              width: 150,
              child: Padding(
                padding: EdgeInsets.only(
                  top: 12.0,
                ), // Sejajarkan dengan baris pertama
                child: Text('Gambar Kelistrikan:'),
              ),
            ),

            // BAGIAN TENGAH (Konten Dinamis)
            Expanded(
              flex: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(4),
                  border: isReady
                      ? null
                      : Border.all(color: Colors.red.shade200),
                ),
                child: isLoadingData
                    ? const SizedBox(
                        height: 24,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : _buildContent(
                        ref,
                        statusCode,
                        displayText,
                        options,
                        selectedId,
                        isEditMode,
                      ),
              ),
            ),

            const SizedBox(width: 10),

            // BAGIAN KANAN (Nomor & Preview)
            Row(
              children: [
                // Indikator Halaman
                SizedBox(
                  width: 70,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isReady
                          ? Colors.yellow.shade200
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Center(
                      child: Text(
                        isReady ? '$pageNumber/$totalHalaman' : '-/-',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent(
    WidgetRef ref,
    String statusCode,
    String displayText,
    List<dynamic> options,
    int? selectedId,
    bool isEditMode,
  ) {
    // KASUS 1: Single Option (Ready)
    if (statusCode == 'ready') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          displayText,
          // style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    // KASUS 2: Multiple Options (Radio Button)
    if (statusCode == 'multiple_options') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                displayText, // "Pilih Opsi Kelistrikan"
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 10),
              Tooltip(
                message: 'Pilih salah satu deskripsi kelistrikan yang sesuai',
                triggerMode: TooltipTriggerMode.tap,
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.lightBlueAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // List Radio Buttons
          ...options.map((opt) {
            final int optId = opt['id'];
            final String optDesc = opt['deskripsi'];

            return RadioListTile<int>(
              title: Text(
                optDesc,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              value: optId,
              groupValue: selectedId,
              contentPadding: EdgeInsets.zero,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              activeColor: Colors.blue,
              // Disable radio jika mode read-only
              onChanged: isEditMode
                  ? (val) {
                      ref.read(selectedKelistrikanIdProvider.notifier).state =
                          val;
                    }
                  : null,
            );
          }),
        ],
      );
    }

    // KASUS 3: Error / Missing
    return Text(
      displayText,
      style: TextStyle(color: Colors.red.shade900, fontStyle: FontStyle.italic),
    );
  }
}
