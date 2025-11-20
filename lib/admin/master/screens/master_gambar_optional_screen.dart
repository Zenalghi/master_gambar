// File: lib/admin/master/screens/master_gambar_optional_screen.dart

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:pdfx/pdfx.dart';
import '../../../app/core/notifiers/refresh_notifier.dart';
import '../widgets/pilih_varian_body_card.dart'; // Widget seleksi yang sama
import '../widgets/gambar_optional_table.dart'; // Tabel list gambar

class MasterGambarOptionalScreen extends ConsumerStatefulWidget {
  const MasterGambarOptionalScreen({super.key});

  @override
  ConsumerState<MasterGambarOptionalScreen> createState() =>
      _MasterGambarOptionalScreenState();
}

class _MasterGambarOptionalScreenState
    extends ConsumerState<MasterGambarOptionalScreen> {
  bool _isLoading = false;
  final _deskripsiController = TextEditingController();
  File? _selectedFile;
  PdfController? _pdfController;

  @override
  void dispose() {
    _deskripsiController.dispose();
    _pdfController?.dispose();
    super.dispose();
  }

  void _resetForm() {
    // Reset provider seleksi (mgu...) agar form kembali bersih
    ref.read(mguSelectedMasterDataIdProvider.notifier).state = null;
    ref.read(mguSelectedVarianBodyIdProvider.notifier).state = null;
    ref.read(mguSelectedVarianBodyNameProvider.notifier).state = null;

    // Reset state lokal
    _deskripsiController.clear();
    setState(() {
      _selectedFile = null;
      _pdfController?.dispose();
      _pdfController = null;
    });
  }

  void _resetAndRefresh() {
    _resetForm();
    // Refresh tabel data
    ref
        .read(gambarOptionalFilterProvider.notifier)
        .update((state) => Map.from(state));
    // Refresh dropdown jika perlu
    ref.read(refreshNotifierProvider.notifier).refresh();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      setState(() {
        _selectedFile = file;
        _pdfController?.dispose();
        _pdfController = PdfController(
          document: PdfDocument.openFile(file.path),
        );
      });
    }
  }

  Future<void> _submit() async {
    // Ambil ID Varian Body dari provider global (hasil pilihan di card)
    final selectedVarianBodyId = ref.read(mguSelectedVarianBodyIdProvider);

    // Validasi Form
    if (selectedVarianBodyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap pilih Varian Body terlebih dahulu.'),
        ),
      );
      return;
    }
    if (_deskripsiController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harap isi deskripsi.')));
      return;
    }
    if (_selectedFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harap pilih file PDF.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(masterDataRepositoryProvider)
          .addGambarOptional(
            varianBodyId: selectedVarianBodyId, // ID untuk relasi independen
            deskripsi: _deskripsiController.text,
            gambarOptionalFile: _selectedFile!,
            tipe: 'independen', // Pastikan tipe independen
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gambar Optional berhasil di-upload!'),
          backgroundColor: Colors.green,
        ),
      );

      _resetForm();
      // Refresh tabel list di bawah
      ref
          .read(gambarOptionalFilterProvider.notifier)
          .update((state) => Map.from(state));
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.response?.data['message'] ?? e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              const Text(
                'Manajemen Gambar Optional',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SizedBox(
                width: 250,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => ref
                      .read(gambarOptionalFilterProvider.notifier)
                      .update((state) => {...state, 'search': value}),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
                onPressed: _resetAndRefresh,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // AREA SCROLLABLE (FORM + TABEL)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 1. CARD PILIH VARIAN BODY (Reuse Widget)
                  const PilihVarianBodyCard(),

                  const SizedBox(height: 16),

                  // 2. CARD INPUT GAMBAR OPTIONAL
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        height: 350,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Kolom Kiri: Form Input
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _deskripsiController,
                                    decoration: const InputDecoration(
                                      labelText: 'Deskripsi Gambar Optional',
                                      border: OutlineInputBorder(),
                                    ),
                                    textCapitalization:
                                        TextCapitalization.characters,
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.picture_as_pdf),
                                    label: Text(
                                      _selectedFile == null
                                          ? 'Pilih File PDF'
                                          : 'Ganti File',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                    ),
                                    onPressed: _pickFile,
                                  ),
                                  if (_selectedFile != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'File: ${_selectedFile!.path.split(Platform.pathSeparator).last}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  const Spacer(),
                                  // TOMBOL UPLOAD
                                  SizedBox(
                                    width: double.infinity,
                                    child: _isLoading
                                        ? const Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : ElevatedButton.icon(
                                            icon: const Icon(Icons.upload),
                                            label: const Text(
                                              'Upload Gambar Optional',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                            ),
                                            onPressed: _submit,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Kolom Kanan: Preview PDF
                            Expanded(
                              flex: 3,
                              child: Card(
                                elevation: 2,
                                clipBehavior: Clip.antiAlias,
                                child: Container(
                                  color: Colors.grey.shade100,
                                  child: _pdfController != null
                                      ? PdfView(
                                          key: ValueKey(_selectedFile!.path),
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
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 8),

                  // 3. TABEL DAFTAR GAMBAR OPTIONAL
                  const SizedBox(
                    height: 600, // Tinggi tetap untuk tabel
                    child: GambarOptionalTable(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
