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
  late final TabController _tabController;
  // State untuk menyimpan path PDF
  Map<String, String>? _paths;
  bool _isLoadingPaths = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchPaths();
  }

  // Method untuk mengambil path dari 3 file
  Future<void> _fetchPaths() async {
    try {
      final paths = await ref
          .read(masterDataRepositoryProvider)
          .getGambarUtamaPaths(widget.gambarUtama.id);
      setState(() {
        _paths = paths;
        _isLoadingPaths = false;
      });
    } catch (e) {
      // Handle error jika gagal mengambil path
      setState(() => _isLoadingPaths = false);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat path gambar: $e')));
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        child: _isLoadingPaths
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Gambar Utama'),
                      Tab(text: 'Gambar Terurai'),
                      Tab(text: 'Gambar Kontruksi'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Gunakan widget helper untuk setiap tab
                        _PdfLazyViewer(path: _paths?['utama']),
                        _PdfLazyViewer(path: _paths?['terurai']),
                        _PdfLazyViewer(path: _paths?['kontruksi']),
                      ],
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
