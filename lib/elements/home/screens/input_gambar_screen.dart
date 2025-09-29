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
    // 1. Aktifkan loading state
    ref.read(isProcessingProvider.notifier).state = true;
    try {
      final pemeriksaId = ref.read(pemeriksaIdProvider);
      final selections = ref.read(gambarUtamaSelectionProvider);
      final showOptional = ref.read(showGambarOptionalProvider);
      final optionalSelections = ref.read(gambarOptionalSelectionProvider);
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
      final judulGambarIds = selections
          .where((s) => s.judulId != null)
          .map((s) => s.judulId!)
          .toList();
      final hGambarOptionalIds = showOptional
          ? optionalSelections
                .where((s) => s.gambarOptionalId != null)
                .map((s) => s.gambarOptionalId!)
                .toList()
          : null;

      if (varianBodyIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih setidaknya satu varian body.')),
        );
        return;
      }

      final pdfData = await ref
          .read(prosesTransaksiRepositoryProvider)
          .getPreviewPdf(
            transaksiId: transaksi.id,
            pemeriksaId: pemeriksaId,
            varianBodyIds: varianBodyIds,
            judulGambarIds: judulGambarIds,
            hGambarOptionalIds: hGambarOptionalIds,
            iGambarKelistrikanId: showKelistrikan ? kelistrikanId : null,
          );

      if (context.mounted) {
        // --- PERBAIKAN LOGIKA PENCARIAN JUDUL ---
        final judulOptions = await ref.read(judulGambarOptionsProvider.future);
        final selection = selections[rowIndex];

        String judulName = 'Preview'; // Nilai default
        if (selection.judulId != null) {
          final matchingJudul = judulOptions.where(
            (e) => e.id == selection.judulId,
          );
          if (matchingJudul.isNotEmpty) {
            judulName = matchingJudul.first.name;
          }
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(
              pdfData: pdfData,
              title: 'Preview - $judulName',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // --- PERBAIKI SNACKBAR AGAR LEBIH LAMA ---
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error Preview: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 8), // Tahan selama 8 detik
            action: SnackBarAction(label: 'TUTUP', onPressed: () {}),
          ),
        );
      }
    } finally {
      // 2. APAPUN YANG TERJADI (SUKSES/GAGAL), SELALU MATIKAN LOADING
      if (context.mounted) {
        ref.read(isProcessingProvider.notifier).state = false;
      }
    }
  }

  // --- METHOD BARU UNTUK PROSES GAMBAR ---
  Future<void> _handleProses(BuildContext context, WidgetRef ref) async {
    // 1. Aktifkan loading state
    ref.read(isProcessingProvider.notifier).state = true;
    try {
      // (Logika pengumpulan data dan pemanggilan repository tetap sama)
      final pemeriksaId = ref.read(pemeriksaIdProvider);
      final selections = ref.read(gambarUtamaSelectionProvider);
      final showOptional = ref.read(showGambarOptionalProvider);
      final optionalSelections = ref.read(gambarOptionalSelectionProvider);
      final showKelistrikan = ref.read(showGambarKelistrikanProvider);
      final kelistrikanId = ref.read(gambarKelistrikanIdProvider);

      final varianBodyIds = selections
          .where((s) => s.varianBodyId != null)
          .map((s) => s.varianBodyId!)
          .toList();
      final judulGambarIds = selections
          .where((s) => s.judulId != null)
          .map((s) => s.judulId!)
          .toList();
      final hGambarOptionalIds = showOptional
          ? optionalSelections
                .where((s) => s.gambarOptionalId != null)
                .map((s) => s.gambarOptionalId!)
                .toList()
          : null;

      final result = await ref
          .read(prosesTransaksiRepositoryProvider)
          .prosesGambar(
            transaksiId: transaksi.id,
            pemeriksaId: pemeriksaId!,
            varianBodyIds: varianBodyIds,
            judulGambarIds: judulGambarIds,
            hGambarOptionalIds: hGambarOptionalIds,
            iGambarKelistrikanId: showKelistrikan ? kelistrikanId : null,
          );

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
        ref.invalidate(transaksiHistoryProvider);
        ref.read(pageStateProvider.notifier).state = PageState(pageIndex: 0);
      }
    } catch (e) {
      if (context.mounted) {
        // --- PERBAIKI SNACKBAR AGAR LEBIH LAMA ---
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error Proses: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 8), // Tahan selama 8 detik
            action: SnackBarAction(label: 'TUTUP', onPressed: () {}),
          ),
        );
      }
    } finally {
      // 2. APAPUN YANG TERJADI (SUKSES/GAGAL), SELALU MATIKAN LOADING
      if (context.mounted) {
        ref.read(isProcessingProvider.notifier).state = false;
      }
    }
  }

  void _resetInputGambarState(WidgetRef ref) {
    // Reset semua provider yang terkait dengan form ini ke nilai defaultnya
    ref.read(isProcessingProvider.notifier).state = false;
    // ref.read(jumlahGambarProvider.notifier).state = 1;
    ref.read(pemeriksaIdProvider.notifier).state = null;
    ref.read(showGambarOptionalProvider.notifier).state = false;
    ref.read(jumlahGambarOptionalProvider.notifier).state = 1;
    ref.invalidate(
      gambarOptionalSelectionProvider,
    ); // Invalidate untuk membuat ulang state
    ref.read(showGambarKelistrikanProvider.notifier).state = false;
    ref.read(gambarKelistrikanIdProvider.notifier).state = null;
    ref.invalidate(gambarUtamaSelectionProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- LOGIKA DINAMIS UTAMA ADA DI SINI ---
    final selections = ref.watch(gambarUtamaSelectionProvider);
    final highestJudulId = selections
        .map((s) => s.judulId ?? 0)
        .fold(0, (max, current) => current > max ? current : max);
    final jumlahGambarUtama = highestJudulId > 0 ? highestJudulId : 1;
    // ----------------------------------------

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gambarUtamaSelectionProvider.notifier).resize(jumlahGambarUtama);
    });

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Teruskan jumlahGambarUtama ke header
          GambarHeaderInfo(
            transaksi: transaksi,
            jumlahGambar: jumlahGambarUtama,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: GambarMainForm(
                transaksi: transaksi,
                onPreviewPressed: (index) =>
                    _handlePreview(context, ref, index),
                jumlahGambarUtama: jumlahGambarUtama, // Teruskan ke main form
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildAksiButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildAksiButton(BuildContext context, WidgetRef ref) {
    final pemeriksaId = ref.watch(pemeriksaIdProvider);
    final selections = ref.watch(gambarUtamaSelectionProvider);
    final bool areSelectionsValid =
        selections.isNotEmpty &&
        selections.every((s) => s.judulId != null && s.varianBodyId != null);
    final bool isFormValid = pemeriksaId != null && areSelectionsValid;
    final isLoading = ref.watch(isProcessingProvider);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: isLoading ? Container() : const Icon(Icons.arrow_forward),
        label: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Text('Proses Gambar'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: isFormValid && !isLoading
            ? () async {
                await _handleProses(context, ref);
                // --- PANGGIL FUNGSI RESET SETELAH PROSES SELESAI ---
                _resetInputGambarState(ref);
              }
            : null,
      ),
    );
  }
}
