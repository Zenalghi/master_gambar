import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/transaksi.dart';
import 'package:master_gambar/elements/home/providers/input_gambar_providers.dart';
import 'package:master_gambar/elements/home/providers/page_state_provider.dart';
import 'package:master_gambar/elements/home/providers/transaksi_providers.dart';
import 'package:master_gambar/elements/home/repository/proses_transaksi_repository.dart';
import 'package:master_gambar/elements/home/screens/pdf_viewer_screen.dart';
import 'package:master_gambar/elements/home/widgets/gambar/gambar_header_info.dart';
import 'package:master_gambar/elements/home/widgets/gambar/gambar_main_form.dart';

class InputGambarScreen extends ConsumerWidget {
  final Transaksi transaksi;

  const InputGambarScreen({super.key, required this.transaksi});

  // Method untuk handle preview (sudah ada)
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
    final judulGambar = selections
        .where((s) => s.judul != null)
        .map((s) => s.judul!)
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
            judulGambar: judulGambar,
            hGambarOptionalId: showOptional ? optionalId : null,
            iGambarKelistrikanId: showKelistrikan ? kelistrikanId : null,
          );

      if (context.mounted) {
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

  // --- METHOD BARU UNTUK PROSES GAMBAR ---
  Future<void> _handleProses(BuildContext context, WidgetRef ref) async {
    // 1. Kumpulkan semua data dari state (sama seperti preview)
    final pemeriksaId = ref.read(pemeriksaIdProvider);
    final selections = ref.read(gambarUtamaSelectionProvider);
    final showOptional = ref.read(showGambarOptionalProvider);
    final optionalId = ref.read(gambarOptionalIdProvider);
    final showKelistrikan = ref.read(showGambarKelistrikanProvider);
    final kelistrikanId = ref.read(gambarKelistrikanIdProvider);

    final varianBodyIds = selections
        .where((s) => s.varianBodyId != null)
        .map((s) => s.varianBodyId!)
        .toList();
    final judulGambar = selections
        .where((s) => s.judul != null)
        .map((s) => s.judul!)
        .toList();

    // 2. Panggil repository dengan aksi 'proses'
    try {
      final result = await ref
          .read(prosesTransaksiRepositoryProvider)
          .prosesGambar(
            transaksiId: transaksi.id,
            pemeriksaId: pemeriksaId!,
            varianBodyIds: varianBodyIds,
            judulGambar: judulGambar,
            hGambarOptionalId: showOptional ? optionalId : null,
            iGambarKelistrikanId: showKelistrikan ? kelistrikanId : null,
          );

      // 3. Tampilkan dialog sukses dan kembali ke halaman utama
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Proses Berhasil'),
            content: Text(
              '${result['message']}\n\nFile disimpan di:\n${result['folder_path']}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        // Refresh tabel histori dan kembali ke halaman utama
        ref.invalidate(transaksiHistoryProvider);
        ref.read(pageStateProvider.notifier).state = PageState(pageIndex: 0);
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

    // Struktur layout dengan header statis dan body scroll
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          GambarHeaderInfo(transaksi: transaksi),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: GambarMainForm(
                transaksi: transaksi,
                onPreviewPressed: (index) =>
                    _handlePreview(context, ref, index),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Panggil method build untuk tombol aksi
          _buildAksiButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildAksiButton(BuildContext context, WidgetRef ref) {
    final pemeriksaId = ref.watch(pemeriksaIdProvider);
    final selections = ref.watch(gambarUtamaSelectionProvider);
    // Validasi: pastikan list tidak kosong sebelum .every()
    final bool areSelectionsValid =
        selections.isNotEmpty &&
        selections.every((s) => s.judul != null && s.varianBodyId != null);
    final bool isFormValid = pemeriksaId != null && areSelectionsValid;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Proses Gambar'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        // --- HUBUNGKAN TOMBOL KE LOGIKA PROSES ---
        onPressed: isFormValid ? () => _handleProses(context, ref) : null,
      ),
    );
  }
}
