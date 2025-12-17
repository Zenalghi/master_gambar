// File: lib/elements/home/screens/input_gambar_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/transaksi.dart';
import 'package:master_gambar/elements/home/providers/input_gambar_providers.dart';
import 'package:master_gambar/elements/home/providers/page_state_provider.dart';
import 'package:master_gambar/elements/home/repository/proses_transaksi_repository.dart';
import 'package:master_gambar/elements/home/widgets/gambar/gambar_header_info.dart';
import 'package:master_gambar/elements/home/widgets/gambar/gambar_main_form.dart';
import 'package:master_gambar/admin/master/widgets/pdf_viewer_dialog.dart';

import '../../../app/core/notifiers/refresh_notifier.dart';

class InputGambarScreen extends ConsumerStatefulWidget {
  final Transaksi transaksi;
  const InputGambarScreen({super.key, required this.transaksi});

  @override
  ConsumerState<InputGambarScreen> createState() => _InputGambarScreenState();
}

class _InputGambarScreenState extends ConsumerState<InputGambarScreen> {
  late TextEditingController _deskripsiOptionalController;

  @override
  void initState() {
    super.initState();
    _deskripsiOptionalController = TextEditingController();

    Future.microtask(() {
      _initOrReloadData();
    });
  }

  @override
  void dispose() {
    _deskripsiOptionalController.dispose();
    super.dispose();
  }

  void _initOrReloadData() {
    // 1. Reset State Provider (Bersih-bersih)
    _resetInputGambarState();

    // 2. Fetch Info Kelistrikan (Update Terbaru dari Admin)
    _fetchKelistrikanInfo();

    // 3. Load Draft History (Jika Ada)
    if (widget.transaksi.detail != null) {
      _loadSavedState(widget.transaksi.detail!);
    }
  }

  void _resetInputGambarState() {
    ref.read(isProcessingProvider.notifier).state = false;
    ref.read(pemeriksaIdProvider.notifier).state = null;
    ref.read(jumlahGambarProvider.notifier).state = 1;
    ref.invalidate(gambarUtamaSelectionProvider);

    // Reset teks deskripsi provider & controller
    ref.read(deskripsiOptionalProvider.notifier).state = '';
    _deskripsiOptionalController.text = '';

    ref.invalidate(varianBodyStatusOptionsProvider);
    ref.read(kelistrikanInfoProvider.notifier).state = null;

    // Invalidate provider otomatis agar fetch ulang saat reset
    // ref.invalidate(independentListNotifierProvider);
    ref.invalidate(dependentOptionalOptionsProvider);
  }

  void _loadSavedState(TransaksiDetail detail) {
    ref.read(pemeriksaIdProvider.notifier).state = detail.pemeriksaId;
    ref.read(jumlahGambarProvider.notifier).state = detail.jumlahGambar;
    ref.read(gambarUtamaSelectionProvider.notifier).resize(detail.jumlahGambar);

    for (int i = 0; i < detail.dataGambarUtama.length; i++) {
      final item = detail.dataGambarUtama[i];
      ref
          .read(gambarUtamaSelectionProvider.notifier)
          .updateSelection(
            i,
            judulId: item['judul_id'],
            varianBodyId: item['varian_id'],
          );
    }

    if (detail.deskripsiOptional != null) {
      ref.read(deskripsiOptionalProvider.notifier).state =
          detail.deskripsiOptional!;
      _deskripsiOptionalController.text = detail.deskripsiOptional!;
    }
  }

  Future<void> _fetchKelistrikanInfo() async {
    ref.read(isLoadingKelistrikanProvider.notifier).state = true;
    try {
      final info = await ref
          .read(prosesTransaksiRepositoryProvider)
          .getKelistrikanByMasterData(widget.transaksi.masterDataId);

      if (mounted) {
        ref.read(kelistrikanInfoProvider.notifier).state = info;
      }
    } catch (e) {
      // Handle error silent
    } finally {
      if (mounted) {
        ref.read(isLoadingKelistrikanProvider.notifier).state = false;
      }
    }
  }

  Future<void> _handlePreview(BuildContext context, int pageNumber) async {
    ref.read(isProcessingProvider.notifier).state = true;
    try {
      final pemeriksaId = ref.read(pemeriksaIdProvider);
      final selections = ref.read(gambarUtamaSelectionProvider);
      final deskripsiOptional = ref.read(deskripsiOptionalProvider);
      final independentAsync = ref.read(independentListNotifierProvider);
      List<int> orderedIndependentIds = [];

      independentAsync.whenData((items) {
        // Map object OptionItem ke List<int> ID
        orderedIndependentIds = items.map((e) => e.id as int).toList();
      });
      // --- Info Kelistrikan ---
      final kelistrikanInfo = ref.read(kelistrikanInfoProvider);
      final statusKelistrikan = kelistrikanInfo?['status_code'];
      final kelistrikanId = kelistrikanInfo?['desc_id'] as int?;
      final bool isKelistrikanReady =
          statusKelistrikan == 'ready' && kelistrikanId != null;

      // --- Validasi Pemeriksa ---
      if (pemeriksaId == null) {
        _showSnackBar('Pilih pemeriksa terlebih dahulu.', Colors.orange);
        return;
      }

      // --- Validasi Row Lengkap (Judul Wajib Diisi) ---
      final hasIncompleteRow = selections.any(
        (s) => s.varianBodyId != null && s.judulId == null,
      );
      if (hasIncompleteRow) {
        _showSnackBar(
          'Mohon lengkapi "Judul Gambar" untuk Varian Body yang telah dipilih.',
          Colors.orange,
        );
        return;
      }

      // --- Ambil Data ID ---
      final varianBodyIds = selections
          .where((s) => s.varianBodyId != null && s.judulId != null)
          .map((s) => s.varianBodyId!)
          .toList();

      final judulGambarIds = selections
          .where((s) => s.varianBodyId != null && s.judulId != null)
          .map((s) => s.judulId!)
          .toList();

      final bool hasVarianBody = varianBodyIds.isNotEmpty;

      // --- Validasi Minimal Konten ---
      if (!hasVarianBody && !isKelistrikanReady) {
        _showSnackBar(
          'Pilih setidaknya satu Varian Body ATAU pastikan Kelistrikan tersedia.',
          Colors.orange,
        );
        return;
      }

      // --- Ambil Data Paket (Dependent) ---
      // Penting: Backend butuh ini untuk memvalidasi Paket Optional mana yang dicentang
      final dependentOptionalIds = ref.read(activeDependentOptionalIdsProvider);

      // --- Logika Smart Page Number ---
      int finalPageNumber = pageNumber;
      if (!hasVarianBody) {
        final jumlahGambarUtama = ref.read(jumlahGambarProvider);
        // Skip halaman Utama, Terurai, Kontruksi, dan Paket
        final int skippedPages =
            (jumlahGambarUtama * 3) + dependentOptionalIds.length;
        finalPageNumber = pageNumber - skippedPages;
        if (finalPageNumber < 1) finalPageNumber = 1;
      }

      // --- Kirim ke Backend ---
      final pdfData = await ref
          .read(prosesTransaksiRepositoryProvider)
          .getPreviewPdf(
            orderedIndependentIds: orderedIndependentIds,
            transaksiId: widget.transaksi.id,
            pemeriksaId: pemeriksaId,
            varianBodyIds: varianBodyIds,

            // WAJIB: Kirim Judul Gambar IDs
            judulGambarIds: judulGambarIds,

            // WAJIB: Kirim Paket Optional IDs
            hGambarOptionalIds: dependentOptionalIds,

            iGambarKelistrikanId: kelistrikanId,
            pageNumber: finalPageNumber,
            deskripsiOptional: deskripsiOptional,
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
        _showSnackBar('Error Preview: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) ref.read(isProcessingProvider.notifier).state = false;
    }
  }

  Future<void> _handleProses(BuildContext context) async {
    ref.read(isProcessingProvider.notifier).state = true;
    try {
      final pemeriksaId = ref.read(pemeriksaIdProvider);
      final selections = ref.read(gambarUtamaSelectionProvider);
      final deskripsiOptional = ref.read(deskripsiOptionalProvider);

      // Info Kelistrikan
      final kelistrikanInfo = ref.read(kelistrikanInfoProvider);
      final kelistrikanId = kelistrikanInfo?['desc_id'] as int?;

      // Filter Data Valid
      final varianBodyIds = selections
          .where((s) => s.varianBodyId != null && s.judulId != null)
          .map((s) => s.varianBodyId!)
          .toList();

      final judulGambarIds = selections
          .where((s) => s.varianBodyId != null && s.judulId != null)
          .map((s) => s.judulId!)
          .toList();

      // WAJIB: Ambil Paket Optional (Dependent)
      final dependentOptionalIds = ref.read(activeDependentOptionalIdsProvider);
      final independentAsync = ref.read(independentListNotifierProvider);
      List<int> orderedIndependentIds = [];

      independentAsync.whenData((items) {
        // Map object OptionItem ke List<int> ID
        orderedIndependentIds = items.map((e) => e.id as int).toList();
      });
      final rawFileName =
          '${widget.transaksi.user.name} (${widget.transaksi.fPengajuan.jenisPengajuan}) '
          '${widget.transaksi.customer.namaPt}_${widget.transaksi.bMerk.merk} '
          '${widget.transaksi.cTypeChassis.typeChassis} (${widget.transaksi.dJenisKendaraan.jenisKendaraan}).zip';
      final suggestedFileName = rawFileName.replaceAll(
        RegExp(r'[\\/:*?"<>|]'),
        '_',
      );

      await ref
          .read(prosesTransaksiRepositoryProvider)
          .downloadProcessedPdfsAsZip(
            transaksiId: widget.transaksi.id,
            suggestedFileName: suggestedFileName,
            pemeriksaId: pemeriksaId!,
            varianBodyIds: varianBodyIds,

            // WAJIB: Kirim parameter lengkap agar Backend memproses semuanya
            judulGambarIds: judulGambarIds,
            hGambarOptionalIds: dependentOptionalIds,
            iGambarKelistrikanId: kelistrikanId,

            deskripsiOptional: deskripsiOptional,
            orderedIndependentIds: orderedIndependentIds,
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
      if (context.mounted)
        _showSnackBar('Error Proses: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) ref.read(isProcessingProvider.notifier).state = false;
    }
  }

  Future<void> _handleSave(BuildContext context) async {
    final pemeriksaId = ref.read(pemeriksaIdProvider);
    if (pemeriksaId == null) {
      _showSnackBar('Pilih pemeriksa untuk menyimpan draft.', Colors.orange);
      return;
    }

    final selections = ref.read(gambarUtamaSelectionProvider);
    List<Map<String, dynamic>> dataGambarUtama = selections
        .map((s) => {'judul_id': s.judulId, 'varian_id': s.varianBodyId})
        .toList();

    try {
      await ref
          .read(prosesTransaksiRepositoryProvider)
          .saveDraft(
            transaksiId: widget.transaksi.id,
            pemeriksaId: pemeriksaId,
            jumlahGambar: ref.read(jumlahGambarProvider),
            dataGambarUtama: dataGambarUtama,
            // Independen Optional & Paket tidak perlu disimpan manual
            // karena backend/frontend sudah otomatis meloadnya berdasarkan Varian ID.
            deskripsiOptional: ref.read(deskripsiOptionalProvider),
          );

      if (mounted) _showSnackBar('Draft berhasil disimpan!', Colors.green);
    } catch (e) {
      if (mounted) _showSnackBar('Gagal simpan: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Widget _buildAksiButton(BuildContext context) {
    final pemeriksaId = ref.watch(pemeriksaIdProvider);
    final selections = ref.watch(gambarUtamaSelectionProvider);

    final bool areSelectionsValid =
        selections.isNotEmpty &&
        selections.every((s) => s.judulId != null && s.varianBodyId != null);
    final bool isFormValid = pemeriksaId != null && areSelectionsValid;
    final isLoading = ref.watch(isProcessingProvider);

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Simpan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => _handleSave(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
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
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: isFormValid && !isLoading
                ? () => _handleProses(context)
                : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(jumlahGambarProvider, (previous, next) {
      ref.read(gambarUtamaSelectionProvider.notifier).resize(next);
    });
    ref.listen(refreshNotifierProvider, (_, __) {
      _initOrReloadData();
    });

    final jumlahGambarUtama = ref.watch(jumlahGambarProvider);

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Column(
        children: [
          GambarHeaderInfo(transaksi: widget.transaksi),
          const SizedBox(height: 5),
          Expanded(
            child: SingleChildScrollView(
              child: GambarMainForm(
                transaksi: widget.transaksi,
                onPreviewPressed: (pageNumber) =>
                    _handlePreview(context, pageNumber),
                jumlahGambarUtama: jumlahGambarUtama,
                deskripsiController: _deskripsiOptionalController,
              ),
            ),
          ),
          const SizedBox(height: 5),
          _buildAksiButton(context),
        ],
      ),
    );
  }
}
