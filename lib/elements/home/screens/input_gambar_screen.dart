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
  // State lokal (opsional, karena data utama ada di provider)
  bool _isLoadingKelistrikan = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _resetInputGambarState();

      if (widget.transaksi.detail != null) {
        _loadSavedState(widget.transaksi.detail!);
      }

      _fetchKelistrikanInfo();
    });
  }

  void _loadSavedState(TransaksiDetail detail) {
    // 1. Pemeriksa & Jumlah Gambar
    ref.read(pemeriksaIdProvider.notifier).state = detail.pemeriksaId;
    ref.read(jumlahGambarProvider.notifier).state = detail.jumlahGambar;

    // Resize list selection provider
    ref.read(gambarUtamaSelectionProvider.notifier).resize(detail.jumlahGambar);

    // 2. Isi Gambar Utama (Looping array)
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

    // 3. Optional Independen
    if (detail.optionalIndependenIds.isNotEmpty) {
      ref.read(showGambarOptionalProvider.notifier).state = true;
      ref.read(jumlahGambarOptionalProvider.notifier).state =
          detail.optionalIndependenIds.length;

      ref
          .read(gambarOptionalSelectionProvider.notifier)
          .resize(detail.optionalIndependenIds.length);
      for (int i = 0; i < detail.optionalIndependenIds.length; i++) {
        ref
            .read(gambarOptionalSelectionProvider.notifier)
            .updateSelection(
              i,
              gambarOptionalId: detail.optionalIndependenIds[i],
            );
      }
    }

    // 4. Deskripsi Optional
    if (detail.deskripsiOptional != null) {
      ref.read(deskripsiOptionalProvider.notifier).state =
          detail.deskripsiOptional!;
    }
  }

  void _resetInputGambarState() {
    ref.read(isProcessingProvider.notifier).state = false;
    ref.read(pemeriksaIdProvider.notifier).state = null;
    ref.read(jumlahGambarProvider.notifier).state = 1;
    ref.invalidate(gambarUtamaSelectionProvider);
    ref.read(showGambarOptionalProvider.notifier).state = false;
    ref.read(jumlahGambarOptionalProvider.notifier).state = 1;
    ref.invalidate(gambarOptionalSelectionProvider);
    ref.read(deskripsiOptionalProvider.notifier).state = '';
    ref.invalidate(varianBodyStatusOptionsProvider);
    ref.read(kelistrikanInfoProvider.notifier).state = null;
  }

  // Fetch data kelistrikan berdasarkan Master Data ID Transaksi
  Future<void> _fetchKelistrikanInfo() async {
    // 1. Set Loading TRUE
    ref.read(isLoadingKelistrikanProvider.notifier).state = true;

    try {
      final info = await ref
          .read(prosesTransaksiRepositoryProvider)
          .getKelistrikanByMasterData(widget.transaksi.masterDataId);

      if (mounted) {
        // Simpan data
        ref.read(kelistrikanInfoProvider.notifier).state = info;
      }
    } catch (e) {
      // Handle error silent
    } finally {
      // 2. Set Loading FALSE (Selesai)
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
      final showOptional = ref.read(showGambarOptionalProvider);
      final optionalSelections = ref.read(gambarOptionalSelectionProvider);
      final deskripsiOptional = ref.read(deskripsiOptionalProvider);

      // VALIDASI KELISTRIKAN BARU
      final kelistrikanInfo = ref.read(kelistrikanInfoProvider);
      final status =
          kelistrikanInfo?['status_code']; // 'ready', 'missing_file', dll
      // Hanya izinkan jika status == 'ready' (File Ada + Deskripsi Ada)
      if (status != 'ready') {
        // Tampilkan pesan error dari backend
        _showSnackBar(
          'Kelistrikan belum siap: ${kelistrikanInfo?['display_text'] ?? "Data tidak valid"}',
          Colors.orange,
        );
        // Opsional: return; jika ingin memblokir preview jika kelistrikan belum siap
        // Tapi biasanya preview halaman lain tetap boleh jalan.
        // Namun preview halaman kelistrikan itu sendiri akan gagal/kosong.
      }

      // Kirim ID deskripsi (jika ada) ke backend preview
      final kelistrikanId = kelistrikanInfo?['desc_id'] as int?;

      if (pemeriksaId == null) {
        _showSnackBar('Pilih pemeriksa terlebih dahulu.', Colors.orange);
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

      if (varianBodyIds.isEmpty) {
        _showSnackBar('Pilih setidaknya satu varian body.', Colors.orange);
        return;
      }

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

      final pdfData = await ref
          .read(prosesTransaksiRepositoryProvider)
          .getPreviewPdf(
            transaksiId: widget.transaksi.id,
            pemeriksaId: pemeriksaId,
            varianBodyIds: varianBodyIds,
            judulGambarIds: judulGambarIds,
            hGambarOptionalIds: allOptionalIds,
            iGambarKelistrikanId: kelistrikanId, // KIRIM ID DESKRIPSI
            pageNumber: pageNumber,
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
      final showOptional = ref.read(showGambarOptionalProvider);
      final optionalSelections = ref.read(gambarOptionalSelectionProvider);
      final deskripsiOptional = ref.read(deskripsiOptionalProvider);

      final kelistrikanInfo = ref.read(kelistrikanInfoProvider);
      final kelistrikanId = kelistrikanInfo?['desc_id'] as int?;
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
            judulGambarIds: judulGambarIds,
            hGambarOptionalIds: allOptionalIds,
            iGambarKelistrikanId: kelistrikanId, // KIRIM ID DESKRIPSI
            deskripsiOptional: deskripsiOptional,
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

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(jumlahGambarProvider, (previous, next) {
      ref.read(gambarUtamaSelectionProvider.notifier).resize(next);
    });

    ref.listen(refreshNotifierProvider, (_, __) {
      _fetchKelistrikanInfo();
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
              ),
            ),
          ),

          const SizedBox(height: 5),

          // Tombol Aksi
          _buildAksiButton(context),
        ],
      ),
    );
  }

  Future<void> _handleSave(BuildContext context) async {
    // Ambil semua data dari provider (mirip _handleProses tapi tanpa validasi ketat)
    final pemeriksaId = ref.read(pemeriksaIdProvider);
    if (pemeriksaId == null) {
      _showSnackBar('Pilih pemeriksa untuk menyimpan draft.', Colors.orange);
      return;
    }

    final selections = ref.read(gambarUtamaSelectionProvider);

    // Siapkan data JSON untuk Gambar Utama
    List<Map<String, dynamic>> dataGambarUtama = selections
        .map((s) => {'judul_id': s.judulId, 'varian_id': s.varianBodyId})
        .toList();

    // Siapkan data Optional
    final showOptional = ref.read(showGambarOptionalProvider);
    final optionalSelections = ref.read(gambarOptionalSelectionProvider);
    List<int> optionalIds = showOptional
        ? optionalSelections
              .where((s) => s.gambarOptionalId != null)
              .map((s) => s.gambarOptionalId!)
              .toList()
        : [];

    try {
      await ref
          .read(prosesTransaksiRepositoryProvider)
          .saveDraft(
            transaksiId: widget.transaksi.id,
            pemeriksaId: pemeriksaId,
            jumlahGambar: ref.read(jumlahGambarProvider),
            dataGambarUtama: dataGambarUtama,
            optionalIds: optionalIds,
            deskripsiOptional: ref.read(deskripsiOptionalProvider),
          );

      if (mounted) _showSnackBar('Draft berhasil disimpan!', Colors.green);
    } catch (e) {
      if (mounted) _showSnackBar('Gagal simpan: $e', Colors.red);
    }
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
        /// ==========================
        /// TOMBOL SIMPAN (BARU)
        /// ==========================
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

        /// ==========================
        /// TOMBOL PROSES (LAMA)
        /// ==========================
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
}
