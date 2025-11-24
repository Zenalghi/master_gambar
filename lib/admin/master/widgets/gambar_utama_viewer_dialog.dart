// File: lib/admin/master/widgets/gambar_utama_viewer_dialog.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/models/g_gambar_utama.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:pdfx/pdfx.dart';

// Widget ini adalah inti dari dialog, mengelola state tab dan pengambilan data
class GambarUtamaViewerDialog extends ConsumerStatefulWidget {
  final GGambarUtama gambarUtama;

  const GambarUtamaViewerDialog({super.key, required this.gambarUtama});

  @override
  ConsumerState<GambarUtamaViewerDialog> createState() =>
      _GambarUtamaViewerDialogState();
}

class _GambarUtamaViewerDialogState
    extends ConsumerState<GambarUtamaViewerDialog>
    with SingleTickerProviderStateMixin {
  // Controller dibuat nullable karena menunggu data dulu
  TabController? _tabController;

  Map<String, String>? _paths;
  bool _isLoadingPaths = true;

  // List dinamis untuk Tab dan View
  List<Tab> _tabs = [];
  List<Widget> _views = [];

  @override
  void initState() {
    super.initState();
    // Jangan inisialisasi TabController di sini
    _fetchPaths();
  }

  Future<void> _fetchPaths() async {
    try {
      final paths = await ref
          .read(masterDataRepositoryProvider)
          .getGambarUtamaPaths(widget.gambarUtama.id);

      // --- LOGIKA DINAMIS MEMBANGUN TAB ---

      // 1. Siapkan List Dasar (3 Tab Wajib)
      List<Tab> tempTabs = [
        const Tab(text: 'Gambar Utama'),
        const Tab(text: 'Gambar Terurai'),
        const Tab(text: 'Gambar Kontruksi'),
      ];

      List<Widget> tempViews = [
        _PdfLazyViewer(path: paths['utama']),
        _PdfLazyViewer(path: paths['terurai']),
        _PdfLazyViewer(path: paths['kontruksi']),
      ];

      // 2. Cek apakah Backend mengirim key 'paket'
      if (paths.containsKey('paket') && paths['paket'] != null) {
        tempTabs.add(const Tab(text: 'Gambar Paket'));
        tempViews.add(_PdfLazyViewer(path: paths['paket']));
      }

      // 3. Update State & Inisialisasi Controller
      if (mounted) {
        setState(() {
          _paths = paths;
          _tabs = tempTabs;
          _views = tempViews;

          // Inisialisasi controller sesuai panjang list yang dinamis (3 atau 4)
          _tabController = TabController(length: _tabs.length, vsync: this);

          _isLoadingPaths = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPaths = false);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat path gambar: $e')));
      }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose(); // Tambahkan ? karena nullable
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pratinjau Gambar Utama'),
      contentPadding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 8.0),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 40.0,
        vertical: 24.0,
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,

        // Tampilkan loading jika controller belum siap
        child: _isLoadingPaths || _tabController == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // TabBar menggunakan list dinamis _tabs
                  TabBar(
                    controller: _tabController,
                    tabs: _tabs,
                    isScrollable:
                        true, // Opsional: agar tab muat jika layar sempit
                    labelColor:
                        Colors.blue, // Styling tambahan agar terlihat aktif
                    unselectedLabelColor: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    // TabBarView menggunakan list dinamis _views
                    child: TabBarView(
                      controller: _tabController,
                      children: _views,
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}

// Widget helper ini bertanggung jawab untuk memuat satu PDF secara "malas"
class _PdfLazyViewer extends ConsumerStatefulWidget {
  final String? path;
  const _PdfLazyViewer({this.path});

  @override
  ConsumerState<_PdfLazyViewer> createState() => _PdfLazyViewerState();
}

class _PdfLazyViewerState extends ConsumerState<_PdfLazyViewer> {
  // Gunakan FutureProvider untuk menangani state loading/error/data
  late final FutureProvider<Uint8List> _pdfDataProvider;

  @override
  void initState() {
    super.initState();
    _pdfDataProvider = FutureProvider<Uint8List>((provRef) {
      // Jika tidak ada path, langsung throw error
      if (widget.path == null) {
        throw Exception('Path PDF tidak ditemukan.');
      }
      // Panggil repository untuk mengunduh PDF
      return ref
          .read(masterDataRepositoryProvider)
          .getPdfFromPath(widget.path!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pdfDataAsync = ref.watch(_pdfDataProvider);

    return pdfDataAsync.when(
      data: (pdfData) => PdfView(
        controller: PdfController(document: PdfDocument.openData(pdfData)),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text(
          'Gagal memuat PDF: ${err.toString()}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
