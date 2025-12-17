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
import '../../../data/models/option_item.dart';
import '../models/gambar_optional.dart';
import '../widgets/pilih_master_data_card.dart';
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

  final ExpansionTileController _expansionController =
      ExpansionTileController();

  @override
  void dispose() {
    _deskripsiController.dispose();
    _pdfController?.dispose();
    super.dispose();
  }

  void _setupEditListener() {
    ref.listen<GambarOptional?>(editingGambarOptionalProvider, (
      previous,
      next,
    ) {
      if (next != null) {
        _enterEditMode(next);
      } else {
        _exitEditMode();
      }
    });
  }

  Future<void> _enterEditMode(GambarOptional item) async {
    // 1. Reset state preview lama
    setState(() {
      _isLoading = true;
      _pdfController?.dispose();
      _pdfController = null;
      _selectedFile = null;
    });

    // 2. Isi Form Deskripsi
    _deskripsiController.text = item.deskripsi;

    // --- PERBAIKAN DI SINI ---

    // CARA LAMA (SALAH): Mengambil via Varian Body (sekarang null)
    // final vb = item.varianBody;
    // final md = vb?.masterData;

    // CARA BARU (BENAR): Mengambil langsung dari properti masterData
    final md = item.masterData;

    if (md != null) {
      // Buat nama gabungan untuk tampilan dropdown
      final masterDataName =
          '${md.typeEngine.name} / ${md.merk.name} / ${md.typeChassis.name} / ${md.jenisKendaraan.name}';

      // Update provider agar PilihMasterDataCard bereaksi
      ref.read(initialGambarUtamaDataProvider.notifier).state = {
        'masterData': OptionItem(id: md.id, name: masterDataName),
        // 'varianBody' tidak diperlukan lagi untuk card ini
      };

      // PENTING: Update juga ID provider yang dipakai saat submit
      ref.read(mguSelectedMasterDataIdProvider.notifier).state = md.id;
    }
    // -------------------------

    try {
      // 4. Download PDF
      final pdfBytes = await ref
          .read(masterDataRepositoryProvider)
          .getGambarOptionalPdf(item.id);

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/edit_opt_${item.id}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await tempFile.writeAsBytes(pdfBytes);

      if (!mounted) return;

      setState(() {
        _pdfController = PdfController(
          document: PdfDocument.openFile(tempFile.path),
        );
      });

      if (!_expansionController.isExpanded) {
        _expansionController.expand();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat preview: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _exitEditMode() {
    _resetForm();
    // if (_expansionController.isExpanded) {
    //   _expansionController.collapse();
    // }
  }

  void _resetForm() {
    ref.read(mguSelectedMasterDataIdProvider.notifier).state = null;
    ref.read(mguSelectedVarianBodyNameProvider.notifier).state = null;
    ref.read(initialGambarUtamaDataProvider.notifier).state =
        null; // Reset dropdown visual

    _deskripsiController.clear();
    setState(() {
      _selectedFile = null;
      _pdfController?.dispose();
      _pdfController = null;
    });
  }

  void _resetAndRefresh() {
    ref.read(editingGambarOptionalProvider.notifier).state = null;
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
    final editingItem = ref.read(editingGambarOptionalProvider);
    final isEditMode = editingItem != null;

    // --- VALIDASI MODE TAMBAH (Create) ---
    // Saat buat baru, SEMUA WAJIB ADA
    if (!isEditMode) {
      if (_selectedFile == null) {
        _showSnackBar('Harap pilih file PDF.', Colors.orange);
        return;
      }
      if (_deskripsiController.text.isEmpty) {
        _showSnackBar('Harap isi deskripsi.', Colors.orange);
        return;
      }
    }

    // --- VALIDASI MODE EDIT (Update) ---
    // Saat edit, minimal salah satu harus berubah (Deskripsi atau File)
    if (isEditMode) {
      // Cek apakah deskripsi berubah dari yang lama?
      final isDeskripsiChanged =
          _deskripsiController.text != editingItem.deskripsi;
      // Cek apakah ada file baru?
      final isFileChanged = _selectedFile != null;

      if (!isDeskripsiChanged && !isFileChanged) {
        _showSnackBar('Tidak ada perubahan data.', Colors.blue);
        return; // Tidak perlu kirim request
      }

      // Pastikan deskripsi tidak dikosongkan total saat edit (opsional, tergantung rule bisnis)
      if (_deskripsiController.text.isEmpty) {
        _showSnackBar('Deskripsi tidak boleh dikosongkan.', Colors.red);
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      if (isEditMode) {
        // --- LOGIKA UPDATE FLEKSIBEL ---
        await ref
            .read(masterDataRepositoryProvider)
            .updateGambarOptional(
              id: editingItem.id,
              // Kirim teks controller (Backend akan update jika dikirim)
              deskripsi: _deskripsiController.text,
              // Kirim file jika ada yang dipilih (null jika tidak ganti)
              file: _selectedFile,
            );

        _showSnackBar('Update Berhasil!', Colors.orange);

        // Reset state edit
        ref.read(editingGambarOptionalProvider.notifier).state = null;
      } else {
        // 1. Ambil ID Master Data (Bukan Varian Body lagi)
        final selectedMasterDataId = ref.read(mguSelectedMasterDataIdProvider);

        if (selectedMasterDataId == null) {
          _showSnackBar(
            'Master Data ID tidak ditemukan. Pilih kendaraan ulang.',
            Colors.red,
          );
          return;
        }

        await ref
            .read(masterDataRepositoryProvider)
            .addGambarOptional(
              // Kirim masterDataId
              masterDataId: selectedMasterDataId,
              deskripsi: _deskripsiController.text,
              gambarOptionalFile: _selectedFile!,
              tipe: 'independen',
            );

        _showSnackBar('Upload Berhasil!', Colors.green);
        _resetForm();
      }

      // Refresh Tabel
      ref
          .read(gambarOptionalFilterProvider.notifier)
          .update((state) => Map.from(state));
    } on DioException catch (e) {
      _showSnackBar(
        'Error: ${e.response?.data['message'] ?? e.message}',
        Colors.red,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _handleCopyAction() {
    // 1. Reset Form Input (Deskripsi & File) tapi JANGAN reset Dropdown
    _deskripsiController.clear();
    setState(() {
      _selectedFile = null;
      _pdfController?.dispose();
      _pdfController = null;
    });

    // 2. Pastikan Mode Edit Mati (Jadi Mode Tambah Baru)
    ref.read(editingGambarOptionalProvider.notifier).state = null;

    // 3. Buka ExpansionTile jika tertutup
    if (!_expansionController.isExpanded) {
      _expansionController.expand();
    }

    // 4. Scroll ke atas (Opsional, agar user sadar form terbuka)
    // (Jika Anda punya ScrollController di SingleChildScrollView utama)

    // 5. Tampilkan SnackBar Instruksi
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hapus snackbar lama
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Data Kendaraan disalin! Silakan isi Deskripsi dan Upload File baru.',
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 4),
        // showCloseIcon: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _setupEditListener();
    ref.listen(copyGambarOptionalTriggerProvider, (previous, next) {
      if (next > 0) {
        _handleCopyAction();
      }
    });
    final editingItem = ref.watch(editingGambarOptionalProvider);
    final isEditMode = editingItem != null;

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
          Row(
            children: [
              const SizedBox(width: 10),
              const Text(
                'Manajemen Gambar Optional',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
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

          ExpansionTile(
            controller: _expansionController,
            initiallyExpanded: isEditMode,
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
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Pilih Kendaraan (Kirim Flag Edit Mode)
                            PilihMasterDataCard(isEditMode: isEditMode),
                            // 2. Input Details
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
                                    Row(
                                      children: [
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
                    Expanded(
                      flex: 2,
                      child: Card(
                        elevation: 2,
                        child: Container(
                          color: Colors.grey.shade100,
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _pdfController != null
                              ? PdfView(
                                  key: ValueKey(
                                    _selectedFile?.path ?? 'server_file',
                                  ),
                                  controller: _pdfController!,
                                )
                              : const Center(
                                  child: const Icon(
                                    Icons.picture_as_pdf_outlined,
                                    color: Colors.grey,
                                    size: 60,
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
          const Expanded(child: GambarOptionalTable()),
        ],
      ),
    );
  }
}
