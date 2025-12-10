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

class InputGambarScreen extends ConsumerStatefulWidget {
  final Transaksi transaksi;

  const InputGambarScreen({super.key, required this.transaksi});

  @override
  ConsumerState<InputGambarScreen> createState() => _InputGambarScreenState();
}

class _InputGambarScreenState extends ConsumerState<InputGambarScreen> {
  // State lokal untuk menyimpan info kelistrikan yang ditemukan
  Map<String, dynamic>? _kelistrikanInfo;
  bool _isLoadingKelistrikan = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _resetInputGambarState();
      _fetchKelistrikanInfo(); // Ambil data kelistrikan saat init
    });
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
  }

  // Fetch data kelistrikan berdasarkan Master Data ID Transaksi
  Future<void> _fetchKelistrikanInfo() async {
    try {
      final info = await ref
          .read(prosesTransaksiRepositoryProvider)
          .getKelistrikanByMasterData(widget.transaksi.masterDataId);

      if (mounted) {
        setState(() {
          _kelistrikanInfo = info;
          _isLoadingKelistrikan = false;
        });
        // SIMPAN KE PROVIDER AGAR BISA DIAKSES WIDGET ANAK
        ref.read(kelistrikanInfoProvider.notifier).state = info;
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingKelistrikan = false);
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

      // VALIDASI KELISTRIKAN
      // Kita pakai ID dari info yang sudah di-fetch
      final kelistrikanId = _kelistrikanInfo?['id'] as int?;

      if (kelistrikanId == null) {
        // Warning jika tidak ada data kelistrikan (optional, tergantung bisnis proses)
        _showSnackBar(
          'Peringatan: Data kelistrikan (Deskripsi) belum diset untuk Master Data ini.',
          Colors.orange,
        );
      }

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

      final kelistrikanId = _kelistrikanInfo?['id'] as int?;

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

    final jumlahGambarUtama = ref.watch(jumlahGambarProvider);

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Column(
        children: [
          GambarHeaderInfo(transaksi: widget.transaksi),
          const SizedBox(height: 5),

          // ----------------------------------------
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

  // Widget Banner Info Kelistrikan
  Widget _buildKelistrikanInfoBanner() {
    if (_isLoadingKelistrikan) {
      return const SizedBox(height: 20, child: LinearProgressIndicator());
    }

    final hasDeskripsi = _kelistrikanInfo?['id'] != null;
    final hasFile = _kelistrikanInfo?['file_id'] != null;
    final deskripsi = _kelistrikanInfo?['deskripsi'] ?? '-';

    Color bgColor;
    IconData icon;
    String text;

    if (hasDeskripsi && hasFile) {
      bgColor = Colors.green.shade50;
      icon = Icons.check_circle;
      text = 'Kelistrikan Terhubung: $deskripsi';
    } else if (hasFile) {
      bgColor = Colors.orange.shade50;
      icon = Icons.warning_amber;
      text =
          'Kelistrikan: File Ada, Tapi Deskripsi Belum Diset (Hubungi Admin)';
    } else {
      bgColor = Colors.red.shade50;
      icon = Icons.error_outline;
      text =
          'Kelistrikan: File PDF Belum Tersedia untuk Chassis ini (Hubungi Admin)';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: bgColor.withOpacity(1).withBlue(200),
        ), // Sedikit menggelapkan border
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
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
            ? () => _handleProses(context)
            : null,
      ),
    );
  }
}
