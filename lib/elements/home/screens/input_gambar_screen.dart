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
  late TextEditingController _deskripsiOptionalController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller
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

  // --- FIX BUG 3: Method Gabungan untuk Init & Reload ---
  void _initOrReloadData() {
    // 1. Reset State Provider (Bersih-bersih)
    _resetInputGambarState();

    // 2. Fetch Info Kelistrikan (Update Terbaru dari Admin)
    _fetchKelistrikanInfo();

    // 3. Load Draft History (Jika Ada)
    // PENTING: Kita load ulang history agar data input user kembali muncul
    if (widget.transaksi.detail != null) {
      _loadSavedState(widget.transaksi.detail!);
    }
  }

  // Helper untuk Reset
  void _resetInputGambarState() {
    ref.read(isProcessingProvider.notifier).state = false;
    ref.read(pemeriksaIdProvider.notifier).state = null;
    ref.read(jumlahGambarProvider.notifier).state = 1;
    ref.invalidate(gambarUtamaSelectionProvider);
    ref.read(showGambarOptionalProvider.notifier).state = false;
    ref.read(jumlahGambarOptionalProvider.notifier).state = 1;
    ref.invalidate(gambarOptionalSelectionProvider);

    // Reset teks deskripsi provider & controller
    ref.read(deskripsiOptionalProvider.notifier).state = '';
    _deskripsiOptionalController.text = '';

    ref.invalidate(varianBodyStatusOptionsProvider);
    ref.read(kelistrikanInfoProvider.notifier).state = null;
  }

  // Helper Load Data History
  void _loadSavedState(TransaksiDetail detail) {
    // ... (Logika 1-4 sama seperti sebelumnya) ...
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

    // 5. Deskripsi Optional (FIX BUG 1)
    if (detail.deskripsiOptional != null) {
      ref.read(deskripsiOptionalProvider.notifier).state =
          detail.deskripsiOptional!;
      _deskripsiOptionalController.text =
          detail.deskripsiOptional!; // Isi Controller!
    }
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

      // --- 1. VALIDASI KELISTRIKAN ---
      final kelistrikanInfo = ref.read(kelistrikanInfoProvider);
      final statusKelistrikan = kelistrikanInfo?['status_code'];
      final kelistrikanId = kelistrikanInfo?['desc_id'] as int?;

      // Cek apakah kelistrikan siap ditampilkan (Status Ready & ID ada)
      final bool isKelistrikanReady =
          statusKelistrikan == 'ready' && kelistrikanId != null;

      // --- 2. VALIDASI PEMERIKSA ---
      if (pemeriksaId == null) {
        _showSnackBar('Pilih pemeriksa terlebih dahulu.', Colors.orange);
        return;
      }

      // --- 3. CEK JUDUL GAMBAR (Mencegah Error Backend) ---
      // Jika user memilih Varian Body tapi LUPA memilih Judul, kita cegah di sini
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

      // Ambil ID yang valid saja (Pasangan Lengkap Varian + Judul)
      final varianBodyIds = selections
          .where((s) => s.varianBodyId != null && s.judulId != null)
          .map((s) => s.varianBodyId!)
          .toList();

      final judulGambarIds = selections
          .where((s) => s.varianBodyId != null && s.judulId != null)
          .map((s) => s.judulId!)
          .toList();

      final bool hasVarianBody = varianBodyIds.isNotEmpty;

      // --- 4. VALIDASI FINAL: MINIMAL ADA SATU KONTEN ---
      // Boleh lanjut jika: (Ada Varian Body) ATAU (Ada Kelistrikan)
      if (!hasVarianBody && !isKelistrikanReady) {
        _showSnackBar(
          'Pilih setidaknya satu Varian Body ATAU pastikan Kelistrikan tersedia.',
          Colors.orange,
        );
        return;
      }

      // --- 5. SIAPKAN DATA OPTIONAL ---
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

      // --- 6. LOGIKA SMART PAGE NUMBER (SOLUSI HALAMAN TIDAK DITEMUKAN) ---
      int finalPageNumber = pageNumber;

      // Jika tidak ada Varian Body yang dikirim, Backend TIDAK akan membuat halaman Utama, Terurai, Kontruksi, dan Paket.
      // Jadi kita harus menggeser nomor halaman preview mundur (agar sesuai dengan PDF yang dihasilkan backend).
      if (!hasVarianBody) {
        final jumlahGambarUtama = ref.read(jumlahGambarProvider);

        // Hitung halaman yang hilang dari PDF (Gambar Utama x3 + Dependent Optionals)
        // Urutan Backend: [Utama, Terurai, Kontruksi] -> [Paket] -> [Independen] -> [Kelistrikan]
        final int skippedPages =
            (jumlahGambarUtama * 3) + dependentOptionalIds.length;

        finalPageNumber = pageNumber - skippedPages;

        // Safety check agar tidak minta halaman 0 atau negatif
        if (finalPageNumber < 1) finalPageNumber = 1;
      }
      // ----------------------------------------------------------------------

      // --- KIRIM KE BACKEND ---
      final pdfData = await ref
          .read(prosesTransaksiRepositoryProvider)
          .getPreviewPdf(
            transaksiId: widget.transaksi.id,
            pemeriksaId: pemeriksaId,
            varianBodyIds: varianBodyIds, // Bisa kosong []
            judulGambarIds: judulGambarIds, // Bisa kosong []
            hGambarOptionalIds: allOptionalIds,
            iGambarKelistrikanId: kelistrikanId,
            pageNumber:
                finalPageNumber, // Gunakan nomor halaman yang sudah disesuaikan
            deskripsiOptional: deskripsiOptional,
          );

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => PdfViewerDialog(
            pdfData: pdfData,
            title:
                'Preview Halaman $pageNumber', // Judul tetap tampilkan halaman asli UI agar user tidak bingung
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
    ref.listen<int>(jumlahGambarOptionalProvider, (previous, next) {
      ref.read(gambarOptionalSelectionProvider.notifier).resize(next);
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
