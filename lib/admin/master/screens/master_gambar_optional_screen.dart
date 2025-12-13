// File: lib/admin/master/screens/master_gambar_optional_screen.dart

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import '../../../app/core/notifiers/refresh_notifier.dart';
import '../models/gambar_optional.dart';
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
  PdfController? _pdfController;

  // Controller untuk ExpansionTile agar bisa dibuka/tutup secara programatis
  final ExpansibleController _expansionController = ExpansibleController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _deskripsiController.dispose();
    _pdfController?.dispose();
    super.dispose();
  }

  // --- LOGIC MODE EDIT ---

  // Listener untuk mendeteksi perubahan mode (Tambah <-> Edit)
  void _setupEditListener() {
    ref.listen<GambarOptional?>(editingGambarOptionalProvider, (
      previous,
      next,
    ) {
      if (next != null) {
        // --- MASUK MODE EDIT ---
        _enterEditMode(next);
      } else {
        // --- KELUAR MODE EDIT ---
        _exitEditMode();
      }
    });
  }

  Future<void> _enterEditMode(GambarOptional item) async {
    // 1. Isi Form dengan Data Lama
    _deskripsiController.text = item.deskripsi;

    // 2. Set Selection Provider (agar dropdown Varian Body terisi - meski disabled)
    // Kita perlu data Varian Body ID dan Master Data ID dari item
    final vb = item.varianBody;
    if (vb != null) {
      // Set ID Master Data (agar dropdown filter varian body jalan)
      ref.read(mguSelectedMasterDataIdProvider.notifier).state =
          item.masterDataId;
      // Set ID Varian Body
      ref.read(mguSelectedVarianBodyIdProvider.notifier).state = vb.id;
      // Set Nama (opsional, untuk UI)
      ref.read(mguSelectedVarianBodyNameProvider.notifier).state = vb.name;
    }

    // 3. Load PDF Preview dari Server (Download sementara ke temp)
    setState(() => _isLoading = true);
    try {
      // Download PDF blob dari backend repository
      final pdfBytes = await ref
          .read(masterDataRepositoryProvider)
          .getGambarOptionalPdf(item.id);

      // Simpan ke temp file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/temp_edit_optional_${item.id}.pdf',
      );
      await tempFile.writeAsBytes(pdfBytes);

      // Tampilkan di PDF Controller
      setState(() {
        _selectedFile =
            null; // Reset file upload lokal (karena kita pakai file server)
        _pdfController?.dispose();
        _pdfController = PdfController(
          document: PdfDocument.openFile(tempFile.path),
        );
      });

      // Buka Panel Expansion
      if (!_expansionController.isExpanded) {
        _expansionController.expand();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat preview: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _exitEditMode() {
    _resetForm(); // Bersihkan form
    _expansionController
        .collapse(); // Tutup panel (opsional, atau biarkan terbuka tapi kosong)
  }

  // -----------------------

  void _resetForm() {
    ref.read(mguSelectedMasterDataIdProvider.notifier).state = null;
    ref.read(mguSelectedVarianBodyIdProvider.notifier).state = null;
    ref.read(mguSelectedVarianBodyNameProvider.notifier).state = null;
    _deskripsiController.clear();
    setState(() {
      _selectedFile = null;
      _pdfController?.dispose();
      _pdfController = null;
    });
  }

  // Tombol Batal / Refresh
  void _resetAndRefresh() {
    ref.read(editingGambarOptionalProvider.notifier).state =
        null; // Keluar mode edit
    _resetForm();
    ref
        .read(gambarOptionalFilterProvider.notifier)
        .update((state) => Map.from(state)); // Refresh tabel
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
    final editingItem = ref.read(editingGambarOptionalProvider);
    final isEditMode = editingItem != null;

    if (!isEditMode) {
      // --- VALIDASI MODE TAMBAH ---
      final selectedVarianBodyId = ref.read(mguSelectedVarianBodyIdProvider);
      if (selectedVarianBodyId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap pilih Varian Body.')),
        );
        return;
      }
      if (_selectedFile == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Harap pilih file PDF.')));
        return;
      }
    }

    if (_deskripsiController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harap isi deskripsi.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (isEditMode) {
        // --- PROSES UPDATE ---
        await ref
            .read(masterDataRepositoryProvider)
            .updateGambarOptional(
              id: editingItem.id,
              deskripsi: _deskripsiController.text,
              file: _selectedFile, // Bisa null jika user tidak ganti file
            );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Update Berhasil!'),
            backgroundColor: Colors.orange,
          ),
        );

        // Keluar mode edit setelah sukses
        ref.read(editingGambarOptionalProvider.notifier).state = null;
      } else {
        // --- PROSES CREATE ---
        final selectedVarianBodyId = ref.read(mguSelectedVarianBodyIdProvider);
        await ref
            .read(masterDataRepositoryProvider)
            .addGambarOptional(
              varianBodyId: selectedVarianBodyId!,
              deskripsi: _deskripsiController.text,
              gambarOptionalFile: _selectedFile!,
              tipe: 'independen',
            );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload Berhasil!'),
            backgroundColor: Colors.green,
          ),
        );
        _resetForm();
      }

      // Refresh Tabel
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
    _setupEditListener(); // Pasang listener

    final editingItem = ref.watch(editingGambarOptionalProvider);
    final isEditMode = editingItem != null;

    // Teks Header Expansion Tile
    String formTitle = 'Tambah Gambar Optional Baru';
    Color headerColor = Colors.black;
    if (isEditMode) {
      formTitle = 'Edit Gambar Optional ${editingItem.tipe.toUpperCase()}';
      headerColor = Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER (Sama)
          Row(
            children: [
              const SizedBox(width: 10),
              const Text(
                'Manajemen Gambar Optional',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // ... search bar ...
              SizedBox(
                width: 250,
                height: 31,
                child: TextField(
                  decoration: const InputDecoration(
                    labelStyle: TextStyle(fontSize: 14),
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
                tooltip: 'Refresh / Batal Edit',
                onPressed: _resetAndRefresh,
              ),
            ],
          ),
          const SizedBox(height: 1),

          // --- EXPANSION TILE (FORM) ---
          ExpansionTile(
            controller: _expansionController, // Pasang controller
            initiallyExpanded: isEditMode, // Auto expand jika mode edit
            title: Text(
              formTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: headerColor,
              ),
            ),
            children: [
              SizedBox(
                height: 400,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === KOLOM KIRI ===
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. PILIH KENDARAAN (DISABLED SAAT EDIT)
                            IgnorePointer(
                              ignoring:
                                  isEditMode, // Matikan interaksi saat edit
                              child: Opacity(
                                opacity: isEditMode
                                    ? 0.6
                                    : 1.0, // Redupkan saat edit
                                child: const PilihVarianBodyCard(),
                              ),
                            ),

                            // 2. INPUT DETAILS
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
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
                                    const SizedBox(height: 5),

                                    // Info Mode Edit (Opsional)
                                    if (isEditMode)
                                      Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        color: Colors.orange.shade50,
                                        child: Text(
                                          "Mode Edit: Anda mengedit data ID #${editingItem.id}. Upload file baru jika ingin mengganti file lama.",
                                          style: TextStyle(
                                            color: Colors.orange.shade900,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),

                                    TextFormField(
                                      controller: _deskripsiController,
                                      decoration: const InputDecoration(
                                        labelText: 'Deskripsi',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.description),
                                      ),
                                      textCapitalization:
                                          TextCapitalization.characters,
                                    ),
                                    const SizedBox(height: 20),

                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.picture_as_pdf),
                                      label: Text(
                                        _selectedFile == null
                                            ? (isEditMode
                                                  ? 'Ganti File (Opsional)'
                                                  : 'Pilih File PDF')
                                            : 'Ganti File Terpilih',
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
                                        child: Text(
                                          'File Baru: ${_selectedFile!.path.split(Platform.pathSeparator).last}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),

                                    const Divider(height: 30),

                                    // TOMBOL ACTION
                                    Row(
                                      children: [
                                        // Tombol Batal (Hanya saat Edit)
                                        if (isEditMode)
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              icon: const Icon(Icons.cancel),
                                              label: const Text('Batal'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.grey,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                    ),
                                              ),
                                              onPressed: _resetAndRefresh,
                                            ),
                                          ),
                                        if (isEditMode)
                                          const SizedBox(width: 10),

                                        // Tombol Simpan
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            icon: Icon(
                                              isEditMode
                                                  ? Icons.save
                                                  : Icons.upload,
                                            ),
                                            label: Text(
                                              isEditMode
                                                  ? 'Simpan Perubahan'
                                                  : 'Upload Baru',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isEditMode
                                                  ? Colors.orange
                                                  : Colors.green,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                            ),
                                            onPressed: _isLoading
                                                ? null
                                                : _submit,
                                          ),
                                        ),
                                      ],
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

                    // === KOLOM KANAN (PREVIEW) ===
                    Expanded(
                      flex: 2,
                      child: Card(
                        elevation: 2,
                        child: Container(
                          color: Colors.grey.shade100,
                          child: _pdfController != null
                              ? PdfView(
                                  key: ValueKey(
                                    _selectedFile?.path ?? 'server_file',
                                  ),
                                  controller: _pdfController!,
                                )
                              : const Center(child: Text("Preview")),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Expanded(child: GambarOptionalTable()),
        ],
      ),
    );
  }
}
