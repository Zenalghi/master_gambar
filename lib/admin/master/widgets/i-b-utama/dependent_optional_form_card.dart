// File: lib/admin/master/widgets/dependent_optional_form_card.dart

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import '../../providers/master_data_providers.dart';

class DependentOptionalFormCard extends ConsumerStatefulWidget {
  final TextEditingController deskripsiController;

  const DependentOptionalFormCard({
    super.key,
    required this.deskripsiController,
  });

  @override
  ConsumerState<DependentOptionalFormCard> createState() =>
      _DependentOptionalFormCardState();
}

class _DependentOptionalFormCardState
    extends ConsumerState<DependentOptionalFormCard> {
  // Logic pick file tetap sama
  Future<void> _pickDependentFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // Wajib true untuk Web
    );

    if (result != null) {
      final file = result.files.single;

      // --- VALIDASI UKURAN FILE (Max 1 MB) ---
      final int sizeInBytes = file.size;
      const int maxBytes = 1024 * 1024; // 1 MB

      if (sizeInBytes > maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Gagal: Ukuran file melebihi 1 MB.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Ekstrak Bytes
      Uint8List? fileBytes = file.bytes;
      if (fileBytes == null && !kIsWeb && file.path != null) {
        fileBytes = File(file.path!).readAsBytesSync();
      }

      // Update provider menggunakan PdfFileData
      if (fileBytes != null) {
        ref.read(mguDependentFileProvider.notifier).state = PdfFileData(
          name: file.name,
          bytes: fileBytes,
          size: sizeInBytes,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dependentFile = ref.watch(mguDependentFileProvider);

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 320,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kolom Kiri: Input
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      controller: widget.deskripsiController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Optional Paket',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Wajib diisi jika checkbox aktif'
                          : null,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: Text(
                        dependentFile == null
                            ? 'Pilih Gambar Optional Paket'
                            : 'Ganti Gambar',
                      ),
                      onPressed: _pickDependentFile,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                      ),
                    ),
                    if (dependentFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          // 2. UBAH CARA PANGGIL NAMA FILE
                          'File: ${dependentFile.name}',
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Kolom Kanan: Preview PDF (REAKTIF)
              Expanded(
                child: Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: dependentFile != null
                        ? _PdfPreviewer(file: dependentFile)
                        : Center(
                            child: Icon(
                              Icons.picture_as_pdf_outlined,
                              size: 40,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET PREVIEWER REAKTIF (DIPERBAIKI UNTUK WEB) ---
class _PdfPreviewer extends StatefulWidget {
  final PdfFileData file;
  const _PdfPreviewer({required this.file});

  @override
  State<_PdfPreviewer> createState() => _PdfPreviewerState();
}

class _PdfPreviewerState extends State<_PdfPreviewer> {
  late PdfController _pdfController;

  @override
  void initState() {
    super.initState();
    // COPY BYTES
    final bytesCopy = Uint8List.fromList(widget.file.bytes);

    _pdfController = PdfController(document: PdfDocument.openData(bytesCopy));
  }

  @override
  void didUpdateWidget(covariant _PdfPreviewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.file.name != oldWidget.file.name ||
        widget.file.size != oldWidget.file.size) {
      _pdfController.dispose();

      // COPY BYTES
      final bytesCopy = Uint8List.fromList(widget.file.bytes);

      _pdfController = PdfController(document: PdfDocument.openData(bytesCopy));
    }
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PdfView(key: ValueKey(widget.file.name), controller: _pdfController);
  }
}
