import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/transaksi.dart';
import 'package:master_gambar/elements/home/providers/input_gambar_providers.dart';

class GambarSyncedRow extends ConsumerWidget {
  final int index;
  final String title;
  final Transaksi transaksi;
  final int totalHalaman;
  final VoidCallback onPreviewPressed;

  const GambarSyncedRow({
    super.key,
    required this.index,
    required this.title,
    required this.transaksi,
    required this.totalHalaman,
    required this.onPreviewPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selections = ref.watch(gambarUtamaSelectionProvider);
    final selection = selections[index];
    final varianBodyOptions = ref.watch(
      varianBodyOptionsFamilyProvider(transaksi.dJenisKendaraan.id),
    );

    // --- 1. Ambil juga data opsi judul ---
    final judulOptions = ref.watch(judulGambarOptionsProvider);

    final bool isRowComplete =
        selection.judulId != null && selection.varianBodyId != null;
    final isLoading = ref.watch(isProcessingProvider);

    // --- 2. Siapkan variabel untuk nama judul dan nama varian ---
    String judulName = '...';
    String varianBodyName = '...';

    // Cari nama judul berdasarkan ID
    judulOptions.whenData((items) {
      if (selection.judulId != null) {
        final selectedItem = items.where((e) => e.id == selection.judulId);
        if (selectedItem.isNotEmpty) {
          judulName = selectedItem.first.name;
        }
      }
    });

    // Cari nama varian berdasarkan ID
    varianBodyOptions.whenData((items) {
      if (selection.varianBodyId != null) {
        final selectedItem = items.where((e) => e.id == selection.varianBodyId);
        if (selectedItem.isNotEmpty) {
          varianBodyName = selectedItem.first.name;
        }
      }
    });

    final basePageNumber = ref.read(jumlahGambarProvider);
    final pageNumber =
        (title.contains('Terurai') ? basePageNumber : basePageNumber * 2) +
        index +
        1;

    return Row(
      children: [
        SizedBox(width: 150, child: Text('$title ${index + 1}:')),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            // --- 3. Tampilkan nama judul di sini ---
            child: Text(judulName),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            // Tampilkan nama varian di sini (ini sudah benar)
            child: Text(varianBodyName),
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
