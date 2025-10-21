import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../admin/master/widgets/pdf_viewer_dialog.dart';
import '../../../app/core/notifiers/refresh_notifier.dart';
import '../../../data/models/transaksi.dart';
import '../providers/input_gambar_providers.dart';
import '../providers/page_state_provider.dart';
import '../repository/proses_transaksi_repository.dart';
import '../widgets/gambar/gambar_header_info.dart';
import '../widgets/gambar/gambar_main_form.dart';
import '../widgets/transaksi_history_datasource.dart';

class InputGambarScreen extends ConsumerWidget {
  final Transaksi transaksi;

  const InputGambarScreen({super.key, required this.transaksi});

  // Method untuk handle preview
  Future<void> _handlePreview(
    BuildContext context,
    WidgetRef ref,
    int pageNumber, // Menerima nomor halaman yang benar
  ) async {
    ref.read(isProcessingProvider.notifier).state = true;
    try {
      final pemeriksaId = ref.read(pemeriksaIdProvider);
      final selections = ref.read(gambarUtamaSelectionProvider);
      final showOptional = ref.read(showGambarOptionalProvider);
      final optionalSelections = ref.read(gambarOptionalSelectionProvider);
      final kelistrikanItem = await ref.read(
        gambarKelistrikanDataProvider(transaksi.cTypeChassis.id).future,
      );
      final kelistrikanId = kelistrikanItem?.id as int?;
      final deskripsiOptional = ref.read(deskripsiOptionalProvider);
      if (pemeriksaId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih pemeriksa terlebih dahulu.')),
        );
        return;
      }

      // Bagian ini tidak berubah, kita tetap butuh semua ID
      final varianBodyIds = selections
          .where((s) => s.varianBodyId != null)
          .map((s) => s.varianBodyId!)
          .toList();
      final judulGambarIds = selections
          .where((s) => s.judulId != null)
          .map((s) => s.judulId!)
          .toList();
      final dependentOptionalIds = ref.read(activeDependentOptionalIdsProvider);
      List<int> independentOptionalIds = showOptional
          ? optionalSelections
                .where((s) => s.gambarOptionalId != null)
                .map((s) => s.gambarOptionalId!)
                .toList()
          : [];
      final allOptionalIds = [
        ...dependentOptionalIds,
        ...independentOptionalIds,
      ];

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
            hGambarOptionalIds: allOptionalIds.isNotEmpty
                ? allOptionalIds
                : null,
            iGambarKelistrikanId: kelistrikanId,
            pageNumber: pageNumber,
            deskripsiOptional: deskripsiOptional.isNotEmpty
                ? deskripsiOptional
                : null,
          );

      // --- PERBAIKAN UTAMA DI SINI ---
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => PdfViewerDialog(
            // Panggil dialog baru
            pdfData: pdfData,
            title: 'Preview Halaman $pageNumber',
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error Preview: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(label: 'TUTUP', onPressed: () {}),
          ),
        );
      }
    } finally {
      if (context.mounted) {
        ref.read(isProcessingProvider.notifier).state = false;
      }
    }
  }

  // Method untuk handle proses
  Future<void> _handleProses(BuildContext context, WidgetRef ref) async {
    ref.read(isProcessingProvider.notifier).state = true;
    try {
      final pemeriksaId = ref.read(pemeriksaIdProvider);
      final selections = ref.read(gambarUtamaSelectionProvider);
      final showOptional = ref.read(showGambarOptionalProvider);
      final optionalSelections = ref.read(gambarOptionalSelectionProvider);
      final kelistrikanItem = await ref.read(
        gambarKelistrikanDataProvider(transaksi.cTypeChassis.id).future,
      );
      final deskripsiOptional = ref.read(deskripsiOptionalProvider);
      final kelistrikanId =
          kelistrikanItem?.id as int?; // Ambil ID-nya, bisa jadi null

      final varianBodyIds = selections
          .where((s) => s.varianBodyId != null)
          .map((s) => s.varianBodyId!)
          .toList();
      final judulGambarIds = selections
          .where((s) => s.judulId != null)
          .map((s) => s.judulId!)
          .toList();

      final dependentOptionalIds = ref.read(activeDependentOptionalIdsProvider);
      // --- PERBAIKAN DI SINI (LOGIKA YANG SAMA DENGAN PREVIEW) ---
      List<int> independentOptionalIds = showOptional
          ? optionalSelections
                .where((s) => s.gambarOptionalId != null)
                .map((s) => s.gambarOptionalId!)
                .toList()
          : [];

      final allOptionalIds = [
        ...dependentOptionalIds,
        ...independentOptionalIds,
      ];
      // -----------------------------------------------------------

      final suggestedFileName =
          '${transaksi.user.name}-${transaksi.customer.namaPt}-${transaksi.cTypeChassis.typeChassis}.zip';

      await ref
          .read(prosesTransaksiRepositoryProvider)
          .downloadProcessedPdfsAsZip(
            transaksiId: transaksi.id,
            suggestedFileName: suggestedFileName,
            pemeriksaId: pemeriksaId!,
            varianBodyIds: varianBodyIds,
            judulGambarIds: judulGambarIds,
            hGambarOptionalIds: allOptionalIds.isNotEmpty
                ? allOptionalIds
                : null,
            iGambarKelistrikanId: kelistrikanId,
            deskripsiOptional: deskripsiOptional.isNotEmpty
                ? deskripsiOptional
                : null,
          );

      if (context.mounted) {
        // Tampilkan dialog sukses setelah download selesai
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Unduhan Berhasil'),
            content: Text('File ZIP berhasil disimpan di perangkat Anda.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        // Reset state dan kembali ke halaman utama
        ref.invalidate(transaksiDataSourceProvider);
        ref.read(pageStateProvider.notifier).state = PageState(pageIndex: 0);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error Proses: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(label: 'TUTUP', onPressed: () {}),
          ),
        );
      }
    } finally {
      if (context.mounted) {
        ref.read(isProcessingProvider.notifier).state = false;
      }
    }
  }

  // Method untuk me-reset semua state form
  void _resetInputGambarState(WidgetRef ref) {
    ref.read(isProcessingProvider.notifier).state = false;
    ref.read(jumlahGambarOptionalProvider.notifier).state = 1;
    ref.read(deskripsiOptionalProvider.notifier).state = '';
    // 1. Reset semua state pilihan di form
    // ref.read(pemeriksaIdProvider.notifier).state = null;
    ref.read(jumlahGambarProvider.notifier).state = 1;
    // invalidate akan mereset StateNotifier ke state awalnya
    ref.invalidate(gambarUtamaSelectionProvider);

    // 2. Tutup dan reset checkbox beserta isinya
    ref.read(showGambarOptionalProvider.notifier).state = false;
    ref.invalidate(gambarOptionalSelectionProvider);

    // 3. Bunyikan "lonceng" untuk memicu FutureProvider mengambil data baru
    ref.read(refreshNotifierProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- PERBAIKAN UTAMA: GUNAKAN ref.listen UNTUK MENCEGAH RACE CONDITION ---
    ref.listen<int>(jumlahGambarProvider, (previous, next) {
      // Saat dropdown jumlah berubah, langsung resize list state.
      // Ini terjadi SEBELUM UI mencoba membangun ulang.
      ref.read(gambarUtamaSelectionProvider.notifier).resize(next);
    });
    // --------------------------------------------------------------------

    // Tonton provider untuk mendapatkan nilai saat ini untuk di-render
    final jumlahGambarUtama = ref.watch(jumlahGambarProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          GambarHeaderInfo(transaksi: transaksi),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: GambarMainForm(
                transaksi: transaksi,
                onPreviewPressed: (index) =>
                    _handlePreview(context, ref, index),
                // Teruskan jumlah yang benar ke widget anak
                jumlahGambarUtama: jumlahGambarUtama,
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
                _resetInputGambarState(ref);
              }
            : null,
      ),
    );
  }
}
