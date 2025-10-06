// File: lib/admin/master/widgets/pilih_file_pdf_card.dart

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:pdfx/pdfx.dart';

class PilihFilePdfCard extends ConsumerWidget {
  final VoidCallback onSubmit;
  final bool isLoading;

  const PilihFilePdfCard({
    super.key,
    required this.onSubmit,
    required this.isLoading,
  });

  Future<File?> _pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2. Pilih File PDF',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isVarianBodySelected ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            _buildFilePicker(
              label: 'Gambar Utama',
              file: gambarUtamaFile,
              onPressed: isVarianBodySelected
                  ? () async {
                      final file = await _pickPdfFile();
                      if (file != null)
                        ref.read(mguGambarUtamaFileProvider.notifier).state =
                            file;
                    }
                  : null,
            ),
            const SizedBox(height: 16),
            _buildFilePicker(
              label: 'Gambar Terurai',
              file: gambarTeruraiFile,
              onPressed: isVarianBodySelected
                  ? () async {
                      final file = await _pickPdfFile();
                      if (file != null)
                        ref.read(mguGambarTeruraiFileProvider.notifier).state =
                            file;
                    }
                  : null,
            ),
            const SizedBox(height: 16),
            _buildFilePicker(
              label: 'Gambar Kontruksi',
              file: gambarKontruksiFile,
              onPressed: isVarianBodySelected
                  ? () async {
                      final file = await _pickPdfFile();
                      if (file != null)
                        ref
                                .read(mguGambarKontruksiFileProvider.notifier)
                                .state =
                            file;
                    }
                  : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.upload),
                      label: const Text('Upload Gambar'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: allFilesSelected ? onSubmit : null,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePicker({
    required String label,
    File? file,
    VoidCallback? onPressed,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kolom untuk Tombol dan Nama File
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
        // Kolom untuk Preview PDF
        Expanded(
          flex: 2,
          child: Container(
            height: 480, // Beri tinggi tetap untuk area preview
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey.shade200,
            ),
            // --- INI PERUBAHAN UTAMANYA ---
            child: file != null
                ? _PdfPreviewer(file: file) // Gunakan widget baru
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

// --- WIDGET BARU UNTUK MENGELOLA STATE PDF CONTROLLER ---
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
    // Controller dibuat HANYA SEKALI saat widget pertama kali dibuat
    _pdfController = PdfController(
      document: PdfDocument.openFile(widget.file.path),
    );
  }

  @override
  void didUpdateWidget(covariant _PdfPreviewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika file berubah (misalnya pengguna memilih file lain untuk slot yang sama)
    if (widget.file.path != oldWidget.file.path) {
      // Buang controller lama dan buat yang baru
      _pdfController.dispose();
      _pdfController = PdfController(
        document: PdfDocument.openFile(widget.file.path),
      );
    }
  }

  @override
  void dispose() {
    // Pastikan controller dibuang saat widget dihancurkan
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PdfView(
      // Beri key unik agar Flutter tahu kapan harus menggambar ulang
      key: ValueKey(widget.file.path),
      controller: _pdfController,
    );
  }
}
