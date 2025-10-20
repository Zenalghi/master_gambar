import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/transaksi.dart';
import 'package:master_gambar/elements/home/providers/input_gambar_providers.dart';

class GambarUtamaRow extends ConsumerWidget {
  final int index;
  final Transaksi transaksi;
  final int totalHalaman;
  final VoidCallback onPreviewPressed; // Tipe diubah menjadi VoidCallback
  final int pageNumber; // Tambahkan ini untuk menampilkan nomor halaman yang benar

  const GambarUtamaRow({
    super.key,
    required this.index,
    required this.transaksi,
    required this.totalHalaman,
    required this.onPreviewPressed,
    required this.pageNumber, // Tambahkan di constructor
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pemeriksaId = ref.watch(pemeriksaIdProvider);
    final selections = ref.watch(gambarUtamaSelectionProvider);
    final selection = selections[index];
    final varianBodyOptions = ref.watch(
      varianBodyOptionsFamilyProvider(transaksi.dJenisKendaraan.id),
    );
    final judulOptions = ref.watch(judulGambarOptionsProvider);
    final bool isRowComplete =
        selection.judulId != null &&
        selection.varianBodyId != null &&
        pemeriksaId != null;
    final isLoading = ref.watch(isProcessingProvider);

    // final pageNumber = (index * 3) + 1;

    return Row(
      children: [
        SizedBox(width: 150, child: Text('Gambar Utama ${index + 1}:')),
        Expanded(
          flex: 2,
          child: judulOptions.when(
            data: (items) => DropdownButtonFormField<int>(
              value: selection.judulId,
              isDense: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: items.map((e) => DropdownMenuItem<int>(value: e.id as int, child: Text(e.name))).toList(),
              onChanged: (value) {
                ref.read(gambarUtamaSelectionProvider.notifier).updateSelection(index, judulId: value);
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => const Text('Error Judul'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: varianBodyOptions.when(
            data: (items) => DropdownButtonFormField<int>(
              value: selection.varianBodyId,
              isDense: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: items.map((e) => DropdownMenuItem<int>(value: e.id as int, child: Text(e.name))).toList(),
              onChanged: (value) {
                ref.read(gambarUtamaSelectionProvider.notifier).updateSelection(index, varianBodyId: value);
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => const Text('Error Varian'),
          ),
        ),
        const SizedBox(width: 10),
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
        SizedBox(
          width: 170,
          child: ElevatedButton(
            onPressed: isRowComplete && !isLoading ? onPreviewPressed : null,
            child: const Text('Preview Gambar'),
          ),
        ),
      ],
    );
  }
}