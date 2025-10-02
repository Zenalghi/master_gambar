import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:pdfx/pdfx.dart'; // <-- 1. Import package pdfx

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

  // --- PERBAIKAN UTAMA ADA DI WIDGET INI ---
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
            child: file != null
                ? PdfView(
                    controller: PdfController(
                      document: PdfDocument.openFile(file.path),
                    ),
                  )
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
