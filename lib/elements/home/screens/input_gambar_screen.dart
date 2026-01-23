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
  bool _hasSavedData = false; // Penanda apakah data sudah tersimpan di DB

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
    _resetInputGambarState();

    // Cek apakah ada data detail yang tersimpan
    if (widget.transaksi.detail != null) {
      _hasSavedData = true;
      // Jika ada data tersimpan, defaultnya adalah READ ONLY (Edit Mode = False)
      ref.read(isEditModeProvider.notifier).state = false;
      _loadSavedState(widget.transaksi.detail!);
    } else {
      _hasSavedData = false;
      // Jika data baru, defaultnya adalah EDITABLE (Edit Mode = True)
      ref.read(isEditModeProvider.notifier).state = true;
    }

    // ---  BATASI JUMLAH GAMBAR UNTUK VARIAN ---
    final jenisPengajuan = widget.transaksi.fPengajuan.jenisPengajuan
        .toUpperCase();
    if (jenisPengajuan == 'VARIAN') {
      final currentJumlah = ref.read(jumlahGambarProvider);
      if (currentJumlah > 3) {
        ref.read(jumlahGambarProvider.notifier).state = 3;
      }
    }
    Future.microtask(() {
      ref
          .read(independentListNotifierProvider.notifier)
          .fetchByMasterData(widget.transaksi.masterDataId);
    });

    _fetchKelistrikanInfo();
  }

  void _resetInputGambarState() {
    ref.read(isProcessingProvider.notifier).state = false;
    ref.read(pemeriksaIdProvider.notifier).state = null;
    ref.read(jumlahGambarProvider.notifier).state = 1;
    ref.invalidate(gambarUtamaSelectionProvider);
    ref.read(deskripsiOptionalProvider.notifier).state = '';
    _deskripsiOptionalController.text = '';
    ref.invalidate(varianBodyStatusOptionsProvider);
    ref.invalidate(dependentOptionalOptionsProvider);
    ref.read(kelistrikanInfoProvider.notifier).state = null;
    ref.read(selectedKelistrikanIdProvider.notifier).state = null;
  }

  void _loadSavedState(TransaksiDetail detail) {
    ref.read(pemeriksaIdProvider.notifier).state = detail.pemeriksaId;
    ref.read(jumlahGambarProvider.notifier).state = detail.jumlahGambar;
    ref.read(gambarUtamaSelectionProvider.notifier).resize(detail.jumlahGambar);
    final jenisPengajuan = widget.transaksi.fPengajuan.jenisPengajuan
        .toUpperCase();
    int jumlahLoad = detail.jumlahGambar;

    // Jika saved data isinya 4 tapi jenisnya VARIAN, paksa jadi 3
    if (jenisPengajuan == 'VARIAN' && jumlahLoad > 3) {
      jumlahLoad = 3;
    }

    ref.read(jumlahGambarProvider.notifier).state = jumlahLoad;
    ref.read(gambarUtamaSelectionProvider.notifier).resize(jumlahLoad);
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
    // TransaksiDetail model sudah punya field 'orderedIndependentIds' (List<int>)

    if (detail.orderedIndependentIds != null &&
        detail.orderedIndependentIds!.isNotEmpty) {
      // Kita panggil applySavedOrder.
      // Note: Ini mungkin perlu delay sedikit agar fetchByMasterData selesai dulu,
      // atau panggil di dalam callback 'whenData' di provider.
      // Cara aman sederhana:
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ref
              .read(independentListNotifierProvider.notifier)
              .applySavedOrder(detail.orderedIndependentIds!);
        }
      });
    }

    if (detail.deskripsiOptional != null) {
      ref.read(deskripsiOptionalProvider.notifier).state =
          detail.deskripsiOptional!;
      _deskripsiOptionalController.text = detail.deskripsiOptional!;
    }
    if (detail.iGambarKelistrikanId != null) {
      ref.read(selectedKelistrikanIdProvider.notifier).state =
          detail.iGambarKelistrikanId;
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
        if (info != null && info['status_code'] == 'ready') {
          ref.read(selectedKelistrikanIdProvider.notifier).state =
              info['selected_id'];
        }
      }
    } catch (e) {
      // Handle silent
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

      independentAsync.whenData((state) {
        // HANYA AMBIL YANG ACTIVE
        orderedIndependentIds = state.activeItems
            .map((e) => e.id as int)
            .toList();
      });
      // --- Info Kelistrikan ---
      final kelistrikanInfo = ref.read(kelistrikanInfoProvider);
      final statusKelistrikan = kelistrikanInfo?['status_code'];
      final kelistrikanId = ref.read(selectedKelistrikanIdProvider);
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
            judulGambarIds: judulGambarIds,
            hGambarOptionalIds: dependentOptionalIds,
            pageNumber: finalPageNumber,
            deskripsiOptional: deskripsiOptional,
            iGambarKelistrikanId: kelistrikanId,
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
      final jenisPengajuan = widget.transaksi.fPengajuan.jenisPengajuan
          .toUpperCase();
      final bool isGambarTU = jenisPengajuan == 'GAMBAR TU';
      final String extension = isGambarTU ? 'pdf' : 'zip';
      final pemeriksaId = ref.read(pemeriksaIdProvider);
      final selections = ref.read(gambarUtamaSelectionProvider);
      final deskripsiOptional = ref.read(deskripsiOptionalProvider);
      // --- Info Kelistrikan ---
      final kelistrikanId = ref.read(selectedKelistrikanIdProvider);

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

      independentAsync.whenData((state) {
        // HANYA AMBIL YANG ACTIVE
        orderedIndependentIds = state.activeItems
            .map((e) => e.id as int)
            .toList();
      });
      final rawFileName =
          '${widget.transaksi.user.name} (${widget.transaksi.fPengajuan.jenisPengajuan}) '
          '${widget.transaksi.customer.namaPt}_${widget.transaksi.bMerk.merk} '
          '${widget.transaksi.cTypeChassis.typeChassis} (${widget.transaksi.dJenisKendaraan.jenisKendaraan}).$extension';

      final suggestedFileName = rawFileName
          .replaceAll(RegExp(r'[\r\n]+'), ' ')
          .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      await ref
          .read(prosesTransaksiRepositoryProvider)
          .downloadProcessedPdfs(
            transaksiId: widget.transaksi.id,
            suggestedFileName: suggestedFileName,
            extension: extension,
            pemeriksaId: pemeriksaId!,
            varianBodyIds: varianBodyIds,
            judulGambarIds: judulGambarIds,
            hGambarOptionalIds: dependentOptionalIds,
            iGambarKelistrikanId: kelistrikanId,
            orderedIndependentIds: orderedIndependentIds,
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

  Future<void> _handleSave(BuildContext context) async {
    final pemeriksaId = ref.read(pemeriksaIdProvider);
    if (pemeriksaId == null) {
      _showSnackBar('Pilih pemeriksa untuk menyimpan draft.', Colors.orange);
      return;
    }
    final kelistrikanId = ref.read(selectedKelistrikanIdProvider);
    final selections = ref.read(gambarUtamaSelectionProvider);
    List<Map<String, dynamic>> dataGambarUtama = selections
        .map((s) => {'judul_id': s.judulId, 'varian_id': s.varianBodyId})
        .toList();
    final independentAsync = ref.read(independentListNotifierProvider);
    List<int> currentOrderedIds = [];
    independentAsync.whenData((state) {
      currentOrderedIds = state.activeItems.map((e) => e.id as int).toList();
    });

    try {
      await ref
          .read(prosesTransaksiRepositoryProvider)
          .saveDraft(
            transaksiId: widget.transaksi.id,
            pemeriksaId: pemeriksaId,
            jumlahGambar: ref.read(jumlahGambarProvider),
            dataGambarUtama: dataGambarUtama,
            orderedIndependentIds: currentOrderedIds,
            deskripsiOptional: ref.read(deskripsiOptionalProvider),
            iGambarKelistrikanId: kelistrikanId,
          );

      if (mounted) {
        _showSnackBar('Draft berhasil disimpan!', Colors.green);
        // SETELAH SIMPAN -> MATIKAN MODE EDIT
        setState(() {
          _hasSavedData = true;
        });
        ref.read(isEditModeProvider.notifier).state = false;
      }
    } catch (e) {
      if (mounted) _showSnackBar('Gagal simpan: $e', Colors.red);
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    // Tampilkan Dialog Konfirmasi
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text(
          'Yakin ingin menghapus seluruh data transaksi ini? Data yang dihapus tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await ref
            .read(prosesTransaksiRepositoryProvider)
            .deleteTransaksi(widget.transaksi.id); // Panggil API Delete

        if (mounted) {
          _showSnackBar('Data berhasil dihapus.', Colors.green);
          // Kembali ke halaman list transaksi
          ref.read(pageStateProvider.notifier).state = PageState(pageIndex: 0);
        }
      } catch (e) {
        if (mounted) _showSnackBar('Gagal menghapus: $e', Colors.red);
      }
    }
  }

  void _toggleEditMode() {
    final isEditMode = ref.read(isEditModeProvider);
    if (isEditMode) {
      // Jika user menekan "Batal Edit"
      // Revert data ke kondisi awal (load ulang dari widget.transaksi jika detail tidak null,
      // tapi idealnya fetch ulang detail terbaru dari API.
      // Sederhananya, kita reset dan load saved state yang ada di memory)
      if (widget.transaksi.detail != null) {
        _loadSavedState(widget.transaksi.detail!);
      }
      ref.read(isEditModeProvider.notifier).state = false;
      _showSnackBar('Edit dibatalkan.', Colors.blue);
    } else {
      // Jika user menekan "Edit"
      ref.read(isEditModeProvider.notifier).state = true;
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating, // Agar melayang
        margin: const EdgeInsets.only(
          bottom: 50, // Angkat setinggi 80px (sesuaikan tinggi tombol Anda)
          left: 50,
          right: 50,
        ),
      ),
    );
  }

  Widget _buildAksiButton(BuildContext context) {
    final pemeriksaId = ref.watch(pemeriksaIdProvider);
    final selections = ref.watch(gambarUtamaSelectionProvider);
    final isEditMode = ref.watch(isEditModeProvider);
    final isLoading = ref.watch(isProcessingProvider);

    final bool areSelectionsValid =
        selections.isNotEmpty &&
        selections.every((s) => s.judulId != null && s.varianBodyId != null);
    final bool isFormValid = pemeriksaId != null && areSelectionsValid;

    // CASE 1: Belum ada data tersimpan (New Data) -> [Simpan] [Proses]
    if (!_hasSavedData) {
      return Row(
        children: [
          Expanded(child: _btnSimpan(context)),
          // const SizedBox(width: 10),
          // Expanded(flex: 2, child: _btnProses(context, isFormValid, isLoading)),
        ],
      );
    }

    // CASE 2: Ada data & Mode Edit Aktif -> [Batal Edit] [Hapus] [Simpan]
    if (isEditMode) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _toggleEditMode,
              child: const Text(
                'Batal Edit',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => _handleDelete(context),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: _btnSimpan(context)),
        ],
      );
    }

    // CASE 3: Ada data & Read Only -> [Edit] [Hapus] [Proses]
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _toggleEditMode,
            child: const Text('Edit', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => _handleDelete(context),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(flex: 2, child: _btnProses(context, isFormValid, isLoading)),
      ],
    );
  }

  // Helper Widget Buttons
  Widget _btnSimpan(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.save),
      label: const Text('Simpan'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: () => _handleSave(context),
    );
  }

  Widget _btnProses(BuildContext context, bool isValid, bool isLoading) {
    return ElevatedButton.icon(
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
      onPressed: isValid && !isLoading ? () => _handleProses(context) : null,
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
