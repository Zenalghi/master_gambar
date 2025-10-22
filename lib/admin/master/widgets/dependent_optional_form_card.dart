// File: lib/admin/master/widgets/dependent_optional_form_card.dart

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import '../providers/master_data_providers.dart';

class DependentOptionalFormCard extends ConsumerStatefulWidget {
  // Kita tambahkan controller deskripsi sebagai parameter agar state-nya
  // tetap dikelola oleh parent (MasterGambarUtamaScreen)
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
  PdfController? _pdfController;

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  Future<void> _pickDependentFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      // Update provider file
      ref.read(mguDependentFileProvider.notifier).state = file;
      // Update state lokal untuk preview
      setState(() {
        _pdfController?.dispose();
        _pdfController = PdfController(
          document: PdfDocument.openFile(file.path),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tonton provider untuk file yang dipilih
    final dependentFile = ref.watch(mguDependentFileProvider);

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 320, // Sesuaikan tinggi jika perlu
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kolom Kiri: Input Deskripsi & Tombol Pilih File
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      controller: widget
                          .deskripsiController, // Gunakan controller dari parent
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Optional Paket',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      // Tambahkan validator jika perlu
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Wajib diisi jika checkbox aktif'
                          : null,
                    ),
                    const Spacer(), // Dorong tombol ke bawah
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
                    // Tampilkan nama file jika sudah dipilih
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
              // Kolom Kanan: Preview PDF
              Expanded(
                child: Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    color: Colors.grey.shade100,
                    child: _pdfController != null
                        ? PdfView(
                            // Beri key agar preview update saat file diganti
                            key: ValueKey(dependentFile!.path),
                            controller: _pdfController!,
                          )
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
