// File: lib/elements/home/screens/input_gambar_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/transaksi.dart';
import 'package:master_gambar/elements/home/providers/input_gambar_providers.dart';
import 'package:master_gambar/elements/home/providers/page_state_provider.dart';
import 'package:master_gambar/elements/home/repository/proses_transaksi_repository.dart';
import 'package:master_gambar/elements/home/widgets/gambar/gambar_header_info.dart';
import 'package:master_gambar/elements/home/widgets/gambar/gambar_main_form.dart';
// import 'package:master_gambar/elements/home/widgets/transaksi_history_datasource.dart';
// Import dialog baru jika sudah dipisah (misal: pdf_viewer_dialog.dart)
import 'package:master_gambar/admin/master/widgets/pdf_viewer_dialog.dart';

// Ubah menjadi StatefulWidget
class InputGambarScreen extends ConsumerStatefulWidget {
  final Transaksi transaksi;

  const InputGambarScreen({super.key, required this.transaksi});

  @override
  ConsumerState<InputGambarScreen> createState() => _InputGambarScreenState();
}

class _InputGambarScreenState extends ConsumerState<InputGambarScreen> {
  @override
  void initState() {
    super.initState();
    // --- RESET STATE OTOMATIS ---
    // Setiap kali masuk halaman ini, pastikan form bersih
    Future.microtask(() => _resetInputGambarState());
  }

  // Method untuk me-reset semua state form
  void _resetInputGambarState() {
    ref.read(isProcessingProvider.notifier).state = false;

    // Reset Provider Utama
    ref.read(pemeriksaIdProvider.notifier).state = null;
    ref.read(jumlahGambarProvider.notifier).state = 1;
    ref.invalidate(gambarUtamaSelectionProvider);

    // Reset Provider Optional
    ref.read(showGambarOptionalProvider.notifier).state = false;
    ref.read(jumlahGambarOptionalProvider.notifier).state = 1;
    ref.invalidate(gambarOptionalSelectionProvider);

    // Reset Deskripsi
    ref.read(deskripsiOptionalProvider.notifier).state = '';
    //varianBodyStatusOptionsProvider
    ref.invalidate(varianBodyStatusOptionsProvider);
  }

  // Method untuk handle preview
  Future<void> _handlePreview(BuildContext context, int pageNumber) async {
    ref.read(isProcessingProvider.notifier).state = true;
    try {
      final pemeriksaId = ref.read(pemeriksaIdProvider);
      final selections = ref.read(gambarUtamaSelectionProvider);
      final showOptional = ref.read(showGambarOptionalProvider);
      final optionalSelections = ref.read(gambarOptionalSelectionProvider);

      // Kelistrikan
      final kelistrikanItem = await ref.read(
        gambarKelistrikanDataProvider(widget.transaksi.cTypeChassis.id).future,
      );
      final kelistrikanId = kelistrikanItem?.id as int?;
      final deskripsiOptional = ref.read(deskripsiOptionalProvider);

      if (pemeriksaId == null) {
        _showError(context, 'Pilih pemeriksa terlebih dahulu.');
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

      // Gabungkan Optional (Paket + Independen)
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
        _showError(context, 'Pilih setidaknya satu varian body.');
        return;
      }

      final pdfData = await ref
          .read(prosesTransaksiRepositoryProvider)
          .getPreviewPdf(
            transaksiId: widget.transaksi.id,
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

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => PdfViewerDialog(
            pdfData: pdfData,
            title: 'Preview Halaman $pageNumber',
          ),
        );
      }
    } catch (e) {
      if (context.mounted)
        _showError(context, 'Error Preview: ${e.toString()}');
    } finally {
      if (mounted) ref.read(isProcessingProvider.notifier).state = false;
    }
  }

  // Method untuk handle proses
  Future<void> _handleProses(BuildContext context) async {
    ref.read(isProcessingProvider.notifier).state = true;
    try {
      final pemeriksaId = ref.read(pemeriksaIdProvider);
      final selections = ref.read(gambarUtamaSelectionProvider);
      final showOptional = ref.read(showGambarOptionalProvider);
      final optionalSelections = ref.read(gambarOptionalSelectionProvider);

      // Kelistrikan
      final kelistrikanItem = await ref.read(
        gambarKelistrikanDataProvider(widget.transaksi.cTypeChassis.id).future,
      );
      final kelistrikanId = kelistrikanItem?.id as int?;
      final deskripsiOptional = ref.read(deskripsiOptionalProvider);

      if (pemeriksaId == null) {
        _showError(context, 'Pilih pemeriksa terlebih dahulu.');
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

      final suggestedFileName =
          '${widget.transaksi.user.name}-${widget.transaksi.customer.namaPt}-${widget.transaksi.cTypeChassis.typeChassis}.zip';

      await ref
          .read(prosesTransaksiRepositoryProvider)
          .downloadProcessedPdfsAsZip(
            transaksiId: widget.transaksi.id,
            suggestedFileName: suggestedFileName,
            pemeriksaId: pemeriksaId,
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
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Unduhan Berhasil'),
            content: const Text(
              'File ZIP berhasil disimpan di perangkat Anda.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        ref.read(pageStateProvider.notifier).state = PageState(pageIndex: 0);
      }
    } catch (e) {
      if (context.mounted) _showError(context, 'Error Proses: ${e.toString()}');
    } finally {
      if (mounted) ref.read(isProcessingProvider.notifier).state = false;
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(jumlahGambarProvider, (previous, next) {
      ref.read(gambarUtamaSelectionProvider.notifier).resize(next);
    });

    final jumlahGambarUtama = ref.watch(jumlahGambarProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Header Info
          GambarHeaderInfo(transaksi: widget.transaksi),

          const SizedBox(height: 10),

          // Main Form Area
          Expanded(
            child: SingleChildScrollView(
              child: GambarMainForm(
                transaksi: widget.transaksi,
                onPreviewPressed: (pageNumber) =>
                    _handlePreview(context, pageNumber),
                jumlahGambarUtama: jumlahGambarUtama,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tombol Aksi
          _buildAksiButton(context),
        ],
      ),
    );
  }

  Widget _buildAksiButton(BuildContext context) {
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
                await _handleProses(context);
              }
            : null,
      ),
    );
  }
}
