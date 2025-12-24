// File: lib/admin/master/widgets/pilih_file_pdf_card.dart

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:pdfx/pdfx.dart';

// UBAH JADI STATEFUL WIDGET AGAR BISA SIMPAN STATE VIEW MODE
class PilihFilePdfCard extends ConsumerStatefulWidget {
  final VoidCallback onSubmit;
  final bool isLoading;

  const PilihFilePdfCard({
    super.key,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  ConsumerState<PilihFilePdfCard> createState() => _PilihFilePdfCardState();
}

class _PilihFilePdfCardState extends ConsumerState<PilihFilePdfCard> {
  // State untuk mode tampilan: True = Horizontal (3 Kolom), False = Vertical (List ke bawah)
  bool _isHorizontalView = true;

  Future<File?> _pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);

      // --- VALIDASI UKURAN FILE (Max 1 MB) ---
      final int sizeInBytes = await file.length();
      const int maxBytes = 1024 * 1024; // 1 MB

      if (sizeInBytes > maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal: Ukuran file melebihi 1 MB.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return null; // Return null agar state tidak berubah
      }

      return file;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isVarianBodySelected =
        ref.watch(mguSelectedVarianBodyIdProvider) != null;

    final gambarUtamaFile = ref.watch(mguGambarUtamaFileProvider);
    final gambarTeruraiFile = ref.watch(mguGambarTeruraiFileProvider);
    final gambarKontruksiFile = ref.watch(mguGambarKontruksiFileProvider);

    final allFilesSelected =
        gambarUtamaFile != null &&
        gambarTeruraiFile != null &&
        gambarKontruksiFile != null;

    return Card(
      color: isVarianBodySelected
          ? null
          : Theme.of(context).cardColor.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER DENGAN TOMBOL TOGGLE ---
            Row(
              children: [
                Text(
                  '2. Pilih File PDF',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isVarianBodySelected ? null : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                // Tombol kecil untuk ganti layout
                InkWell(
                  onTap: () {
                    setState(() {
                      _isHorizontalView = !_isHorizontalView;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      // Ganti icon sesuai mode
                      _isHorizontalView
                          ? Icons
                                .view_list // Icon untuk switch ke Vertical
                          : Icons
                                .view_column, // Icon untuk switch ke Horizontal
                      size: 20,
                      color: Colors.blue,
                    ),
                  ),
                ),
                if (!isVarianBodySelected) ...[
                  const SizedBox(width: 8),
                  const Text(
                    '(Pilih Varian Body dulu)',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 1),

            // --- PILIH LAYOUT BERDASARKAN STATE ---
            if (_isHorizontalView)
              _buildHorizontalLayout(
                isVarianBodySelected,
                gambarUtamaFile,
                gambarTeruraiFile,
                gambarKontruksiFile,
              )
            else
              _buildVerticalLayout(
                isVarianBodySelected,
                gambarUtamaFile,
                gambarTeruraiFile,
                gambarKontruksiFile,
              ),

            const SizedBox(height: 10),

            // Tombol Upload
            SizedBox(
              width: double.infinity,
              height: 34,
              child: widget.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.upload),
                      label: const Text('Upload Gambar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: allFilesSelected ? widget.onSubmit : null,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // === LAYOUT 1: HORIZONTAL (YANG BARU) ===
  Widget _buildHorizontalLayout(
    bool enabled,
    File? fUtama,
    File? fTerurai,
    File? fKontruksi,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildHorizontalItem(
            label: 'Gambar Utama',
            file: fUtama,
            onPressed: enabled
                ? () async {
                    final f = await _pickPdfFile();
                    if (f != null) {
                      ref.read(mguGambarUtamaFileProvider.notifier).state = f;
                    }
                  }
                : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildHorizontalItem(
            label: 'Gambar Terurai',
            file: fTerurai,
            onPressed: enabled
                ? () async {
                    final f = await _pickPdfFile();
                    if (f != null) {
                      ref.read(mguGambarTeruraiFileProvider.notifier).state = f;
                    }
                  }
                : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildHorizontalItem(
            label: 'Gambar Kontruksi',
            file: fKontruksi,
            onPressed: enabled
                ? () async {
                    final f = await _pickPdfFile();
                    if (f != null) {
                      ref.read(mguGambarKontruksiFileProvider.notifier).state =
                          f;
                    }
                  }
                : null,
          ),
        ),
      ],
    );
  }

  // === LAYOUT 2: VERTICAL (YANG LAMA - DITUMPUK) ===
  Widget _buildVerticalLayout(
    bool enabled,
    File? fUtama,
    File? fTerurai,
    File? fKontruksi,
  ) {
    return Column(
      children: [
        _buildVerticalItem(
          label: 'Gambar Utama',
          file: fUtama,
          onPressed: enabled
              ? () async {
                  final f = await _pickPdfFile();
                  if (f != null) {
                    ref.read(mguGambarUtamaFileProvider.notifier).state = f;
                  }
                }
              : null,
        ),
        const SizedBox(height: 16),
        _buildVerticalItem(
          label: 'Gambar Terurai',
          file: fTerurai,
          onPressed: enabled
              ? () async {
                  final f = await _pickPdfFile();
                  if (f != null) {
                    ref.read(mguGambarTeruraiFileProvider.notifier).state = f;
                  }
                }
              : null,
        ),
        const SizedBox(height: 16),
        _buildVerticalItem(
          label: 'Gambar Kontruksi',
          file: fKontruksi,
          onPressed: enabled
              ? () async {
                  final f = await _pickPdfFile();
                  if (f != null) {
                    ref.read(mguGambarKontruksiFileProvider.notifier).state = f;
                  }
                }
              : null,
        ),
      ],
    );
  }

  // --- ITEM WIDGET UTK HORIZONTAL (Input ATAS, Preview BAWAH) ---
  Widget _buildHorizontalItem({
    required String label,
    File? file,
    VoidCallback? onPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            file?.path.split(Platform.pathSeparator).last ??
                'Belum ada file...',
            style: TextStyle(
              color: file != null ? Colors.black : Colors.grey,
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.picture_as_pdf, size: 18),
          label: Text(label, style: const TextStyle(fontSize: 13)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 248,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey.shade200,
          ),
          child: file != null
              ? _PdfPreviewer(file: file)
              : const Center(
                  child: Icon(
                    Icons.picture_as_pdf_outlined,
                    color: Colors.grey,
                    size: 32,
                  ),
                ),
        ),
      ],
    );
  }

  // --- ITEM WIDGET UTK VERTICAL (Input KIRI, Preview KANAN) ---
  Widget _buildVerticalItem({
    required String label,
    File? file,
    VoidCallback? onPressed,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kiri: Input
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  file?.path.split(Platform.pathSeparator).last ??
                      'Belum ada file dipilih...',
                  style: TextStyle(
                    color: file != null ? Colors.black : Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(label),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Kanan: Preview
        Expanded(
          flex: 3,
          child: Container(
            height: 400, // Lebih tinggi untuk mode vertical
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey.shade200,
            ),
            child: file != null
                ? _PdfPreviewer(file: file)
                : const Center(
                    child: Icon(
                      Icons.picture_as_pdf_outlined,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

// --- CLASS PDF PREVIEWER TETAP SAMA ---
class _PdfPreviewer extends StatefulWidget {
  final File file;
  const _PdfPreviewer({required this.file});
  @override
  State<_PdfPreviewer> createState() => _PdfPreviewerState();
}

class _PdfPreviewerState extends State<_PdfPreviewer> {
  late PdfController _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfController(
      document: PdfDocument.openFile(widget.file.path),
    );
  }

  @override
  void didUpdateWidget(covariant _PdfPreviewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.file.path != oldWidget.file.path) {
      _pdfController.dispose();
      _pdfController = PdfController(
        document: PdfDocument.openFile(widget.file.path),
      );
    }
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PdfView(key: ValueKey(widget.file.path), controller: _pdfController);
  }
}
