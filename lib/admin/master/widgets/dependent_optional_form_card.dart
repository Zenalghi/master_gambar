// File: lib/admin/master/widgets/dependent_optional_form_card.dart

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import '../providers/master_data_providers.dart';

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
        return;
      }

      // Update provider jika lolos validasi
      ref.read(mguDependentFileProvider.notifier).state = file;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Tonton Provider
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
                          'File: ${dependentFile.path.split(Platform.pathSeparator).last}',
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
                    color: Colors.grey.shade100,
                    // 2. Gunakan Widget Previewer Khusus
                    // Jika file ada (baik dari pick maupun dari load existing), widget ini akan muncul
                    child: dependentFile != null
                        ? _PdfPreviewer(file: dependentFile)
                        : const Center(
                            child: Icon(
                              Icons.picture_as_pdf_outlined,
                              size: 40,
                              color: Colors.grey,
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

// --- WIDGET PREVIEWER REAKTIF ---
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
    // Jika file berubah, reset controller
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
    // Beri Key unik agar flutter tahu harus render ulang jika path berubah
    return PdfView(key: ValueKey(widget.file.path), controller: _pdfController);
  }
}
