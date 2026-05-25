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
  final int pageNumber;

  const GambarSyncedRow({
    super.key,
    required this.index,
    required this.title,
    required this.transaksi,
    required this.totalHalaman,
    required this.onPreviewPressed,
    required this.pageNumber,
    required int jumlahGambarUtama,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selections = ref.watch(gambarUtamaSelectionProvider);
    final pemeriksaId = ref.watch(pemeriksaIdProvider);
    final isLoading = ref.watch(isProcessingProvider);

    // --- LOGIKA PIHAK PENYETUJUAN ---
    final pihakPenyetujuan = ref.watch(pihakPenyetujuanProvider);
    final bool isPemeriksaValid =
        pihakPenyetujuan == 'customer' || pemeriksaId != null;
    // --------------------------------

    if (index >= selections.length) {
      return const SizedBox.shrink();
    }

    final selection = selections[index];
    final varianBodyOptions = ref.watch(
      varianBodyOptionsFamilyProvider(transaksi.masterDataId),
    );
    final judulOptions = ref.watch(judulGambarOptionsProvider);
    final scheme = Theme.of(context).colorScheme;
    final badgeContainerColor = scheme.brightness == Brightness.dark
        ? const Color(0xFF5A4700)
        : const Color(0xFFFFF3B0);
    final badgeTextColor = scheme.brightness == Brightness.dark
        ? const Color(0xFFFFF4C7)
        : Colors.black87;

    // --- UPDATE VALIDASI ROW ---
    final bool isRowComplete =
        selection.judulId != null &&
        selection.varianBodyId != null &&
        isPemeriksaValid;
    // ---------------------------

    String judulName = '...';
    judulOptions.whenData((items) {
      if (selection.judulId != null) {
        final selectedItem = items.where((e) => e.id == selection.judulId);
        if (selectedItem.isNotEmpty) {
          judulName = selectedItem.first.name;
        }
      }
    });

    String varianBodyName = '...';
    varianBodyOptions.whenData((items) {
      if (selection.varianBodyId != null) {
        final selectedItem = items.where((e) => e.id == selection.varianBodyId);
        if (selectedItem.isNotEmpty) {
          varianBodyName = selectedItem.first.name;
        }
      }
    });

    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(
            '$title ${index + 1}:',
            style: TextStyle(color: scheme.onSurface),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(judulName, style: TextStyle(color: scheme.onSurface)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              varianBodyName,
              style: TextStyle(color: scheme.onSurface),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: badgeContainerColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Center(
              child: Text(
                '$pageNumber/$totalHalaman',
                style: TextStyle(color: badgeTextColor),
              ),
            ),
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
