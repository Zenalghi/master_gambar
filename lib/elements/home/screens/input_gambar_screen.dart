// lib/elements/home/screens/input_gambar_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/transaksi.dart';
import 'package:master_gambar/elements/home/providers/input_gambar_providers.dart';
import 'package:master_gambar/elements/home/repository/proses_transaksi_repository.dart';
import 'package:master_gambar/elements/home/screens/pdf_viewer_screen.dart';
import 'package:master_gambar/elements/home/widgets/gambar/gambar_header_info.dart';
import 'package:master_gambar/elements/home/widgets/gambar/gambar_main_form.dart';

class InputGambarScreen extends ConsumerWidget {
  final Transaksi transaksi;

  const InputGambarScreen({super.key, required this.transaksi});

  // --- PERBAIKAN 1: Tambahkan parameter 'int rowIndex' ---
  Future<void> _handlePreview(
    BuildContext context,
    WidgetRef ref,
    int rowIndex,
  ) async {
    final pemeriksaId = ref.read(pemeriksaIdProvider);
    final selections = ref.read(gambarUtamaSelectionProvider);
    final showOptional = ref.read(showGambarOptionalProvider);
    final optionalId = ref.read(gambarOptionalIdProvider);
    final showKelistrikan = ref.read(showGambarKelistrikanProvider);
    final kelistrikanId = ref.read(gambarKelistrikanIdProvider);

    if (pemeriksaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih pemeriksa terlebih dahulu.')),
      );
      return;
    }

    final varianBodyIds = selections
        .where((s) => s.varianBodyId != null)
        .map((s) => s.varianBodyId!)
        .toList();

    if (varianBodyIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih setidaknya satu varian body.')),
      );
      return;
    }

    try {
      final pdfData = await ref
          .read(prosesTransaksiRepositoryProvider)
          .getPreviewPdf(
            transaksiId: transaksi.id,
            pemeriksaId: pemeriksaId,
            varianBodyIds: varianBodyIds,
            hGambarOptionalId: showOptional ? optionalId : null,
            iGambarKelistrikanId: showKelistrikan ? kelistrikanId : null,
          );

      if (context.mounted) {
        // Gunakan rowIndex untuk mendapatkan judul yang benar
        final previewTitle = selections.length > rowIndex
            ? selections[rowIndex].judul ?? 'Preview'
            : 'Preview';
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(
              pdfData: pdfData,
              title: 'Preview - $previewTitle',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<int>(jumlahGambarProvider, (previous, next) {
      ref.read(gambarUtamaSelectionProvider.notifier).resize(next);
    });

    return Scaffold(
      appBar: AppBar(title: Text('Input Gambar - ID: ${transaksi.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GambarHeaderInfo(transaksi: transaksi),
            const SizedBox(height: 24),
            GambarMainForm(
              transaksi: transaksi,
              // --- PERBAIKAN 2: Salurkan fungsi dengan menyertakan index ---
              onPreviewPressed: (index) => _handlePreview(context, ref, index),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildProsesButton(ref),
    );
  }

  Widget? _buildProsesButton(WidgetRef ref) {
    final pemeriksaId = ref.watch(pemeriksaIdProvider);
    final selections = ref.watch(gambarUtamaSelectionProvider);
    final bool areSelectionsValid = selections.every(
      (s) => s.judul != null && s.varianBodyId != null,
    );
    final bool isFormValid = pemeriksaId != null && areSelectionsValid;
    if (!isFormValid) return null;
    return FloatingActionButton.extended(
      onPressed: () {},
      label: const Text('Proses Gambar'),
      icon: const Icon(Icons.arrow_forward),
    );
  }
}
