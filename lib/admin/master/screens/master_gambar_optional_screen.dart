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
import '../widgets/pilih_varian_body_card.dart';
import '../widgets/gambar_optional_table.dart';

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

  // Kita gunakan Controller yang bisa didispose/recreate manual
  PdfController? _pdfController;

  @override
  void dispose() {
    _deskripsiController.dispose();
    _pdfController?.dispose();
    super.dispose();
  }

  void _resetForm() {
    // Reset provider seleksi
    // ref.read(mguSelectedMasterDataIdProvider.notifier).state = null;
    // ref.read(mguSelectedVarianBodyIdProvider.notifier).state = null;
    // ref.read(mguSelectedVarianBodyNameProvider.notifier).state = null;

    // Reset state lokal
    _deskripsiController.clear();
    setState(() {
      _selectedFile = null;
      _pdfController?.dispose();
      _pdfController = null;
    });
  }

  void _resetAndRefresh() {
    ref.read(mguSelectedMasterDataIdProvider.notifier).state = null;
    ref.read(mguSelectedVarianBodyIdProvider.notifier).state = null;
    ref.read(mguSelectedVarianBodyNameProvider.notifier).state = null;
    _resetForm();
    ref
        .read(gambarOptionalFilterProvider.notifier)
        .update((state) => Map.from(state));
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
    final selectedVarianBodyId = ref.read(mguSelectedVarianBodyIdProvider);

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
            varianBodyId: selectedVarianBodyId,
            deskripsi: _deskripsiController.text,
            gambarOptionalFile: _selectedFile!,
            tipe: 'independen',
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gambar Optional berhasil di-upload!'),
          backgroundColor: Colors.green,
        ),
      );

      _resetForm();
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

          // --- AREA UTAMA (ROW BESAR) ---
          // Menggunakan Expanded agar tabel di bawahnya tetap terlihat jika scroll
          // atau kita batasi tingginya agar rapi.
          ExpansionTile(
            title: const Text('Tambah Gambar Optional Baru'),
            children: [
              SizedBox(
                height: 580, // Tinggi area Input + Preview
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === KOLOM KIRI: SEMUA FORM INPUT ===
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. CARD PILIH KENDARAAN
                            const PilihVarianBodyCard(),

                            const SizedBox(height: 16),

                            // 2. CARD INPUT DESKRIPSI & FILE
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      "2. Detail Gambar",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Input Deskripsi
                                    TextFormField(
                                      controller: _deskripsiController,
                                      decoration: const InputDecoration(
                                        labelText: 'Deskripsi Gambar Optional',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.description),
                                      ),
                                      textCapitalization:
                                          TextCapitalization.characters,
                                    ),
                                    const SizedBox(height: 16),

                                    // Tombol Pilih File
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
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          child: Text(
                                            'File terpilih: ${_selectedFile!.path.split(Platform.pathSeparator).last}',
                                            style: TextStyle(
                                              color: Colors.blue[800],
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    const Divider(),
                                    // const SizedBox(height: 100),

                                    // TOMBOL UPLOAD
                                    SizedBox(
                                      width: double.infinity,
                                      child: _isLoading
                                          ? const Center(
                                              child:
                                                  CircularProgressIndicator(),
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
                                                elevation: 2,
                                              ),
                                              onPressed: _submit,
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // === KOLOM KANAN: PREVIEW PDF FULL HEIGHT ===
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
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.picture_as_pdf_outlined,
                                        size: 60,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        "Preview PDF akan muncul di sini",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),

          // TABEL DAFTAR GAMBAR OPTIONAL
          const Expanded(
            // Mengisi sisa ruang ke bawah
            child: GambarOptionalTable(),
          ),
        ],
      ),
    );
  }
}
