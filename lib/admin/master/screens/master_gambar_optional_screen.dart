import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:pdfx/pdfx.dart';

import '../repository/master_data_repository.dart';
import '../widgets/gambar_optional_table.dart';

class MasterGambarOptionalScreen extends ConsumerStatefulWidget {
  const MasterGambarOptionalScreen({super.key});
  @override
  ConsumerState<MasterGambarOptionalScreen> createState() =>
      _MasterGambarOptionalScreenState();
}

class _MasterGambarOptionalScreenState
    extends ConsumerState<MasterGambarOptionalScreen> {
  // Hanya state untuk controller, file, dan loading yang disimpan di sini
  final _deskripsiController = TextEditingController();
  File? _gambarOptionalFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() => _gambarOptionalFile = File(result.files.single.path!));
    }
  }

  Future<void> _submit() async {
    // Baca state langsung dari provider
    final selectedVarianBodyId = ref.read(mguSelectedVarianBodyIdProvider);

    if (selectedVarianBodyId == null ||
        _deskripsiController.text.isEmpty ||
        _gambarOptionalFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua field dan pilih file PDF.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref
          .read(masterDataRepositoryProvider)
          .addGambarOptional(
            varianBodyId: selectedVarianBodyId,
            deskripsi: _deskripsiController.text,
            gambarOptionalFile: _gambarOptionalFile!,
          );

      // Reset semua provider
      ref.read(mguSelectedTypeEngineIdProvider.notifier).state = null;
      ref.read(mguSelectedMerkIdProvider.notifier).state = null;
      ref.read(mguSelectedTypeChassisIdProvider.notifier).state = null;
      ref.read(mguSelectedJenisKendaraanIdProvider.notifier).state = null;
      ref.read(mguSelectedVarianBodyIdProvider.notifier).state = null;

      // Reset state lokal
      setState(() {
        _gambarOptionalFile = null;
        _deskripsiController.clear();
      });

      ref.invalidate(gambarOptionalListProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gambar Optional berhasil di-upload!'),
          backgroundColor: Colors.green,
        ),
      );
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.response?.data['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tonton provider di sini untuk mendapatkan nilai dan me-rebuild UI
    final selectedVarianBodyId = ref.watch(mguSelectedVarianBodyIdProvider);
    final isVarianBodySelected = selectedVarianBodyId != null;
    final allFilesSelected = _gambarOptionalFile != null;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manajemen Gambar Optional',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // --- WIDGET 1: FORM INPUT DENGAN LAYOUT BARU ---
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kolom Kiri: Form Fields
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildTypeEngineDropdown()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildMerkDropdown()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildTypeChassisDropdown()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildJenisKendaraanDropdown()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildVarianBodyDropdown(),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _deskripsiController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Deskripsi Gambar Optional',
                          ),
                          enabled: isVarianBodySelected,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('Pilih Gambar'),
                              onPressed: isVarianBodySelected
                                  ? _pickPdfFile
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : ElevatedButton.icon(
                                      icon: const Icon(Icons.upload),
                                      label: const Text('Upload Gambar'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      ),
                                      onPressed: allFilesSelected
                                          ? _submit
                                          : null,
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Kolom Kanan: Preview PDF
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey.shade200,
                      ),
                      child: _gambarOptionalFile != null
                          ? PdfView(
                              controller: PdfController(
                                document: PdfDocument.openFile(
                                  _gambarOptionalFile!.path,
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.image_search,
                                color: Colors.grey,
                                size: 50,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Daftar Gambar Optional',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Widget 2: Tabel Data
          const Expanded(child: GambarOptionalTable()),
        ],
      ),
    );
  }
  // Masing-masing sekarang terhubung langsung ke provider

  Widget _buildTypeEngineDropdown() {
    final typeEngineOptions = ref.watch(typeEngineListProvider);
    final selectedId = ref.watch(mguSelectedTypeEngineIdProvider);
    return typeEngineOptions.when(
      data: (options) => DropdownButtonFormField<String>(
        value: selectedId,
        decoration: const InputDecoration(labelText: 'Type Engine'),
        items: options
            .map(
              (opt) => DropdownMenuItem(value: opt.id, child: Text(opt.name)),
            )
            .toList(),
        onChanged: (value) {
          ref.read(mguSelectedTypeEngineIdProvider.notifier).state = value;
          ref.read(mguSelectedMerkIdProvider.notifier).state = null;
          ref.read(mguSelectedTypeChassisIdProvider.notifier).state = null;
          ref.read(mguSelectedJenisKendaraanIdProvider.notifier).state = null;
          ref.read(mguSelectedVarianBodyIdProvider.notifier).state = null;
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const Text('Error'),
    );
  }

  Widget _buildMerkDropdown() {
    final selectedTypeEngineId = ref.watch(mguSelectedTypeEngineIdProvider);
    final merkOptions = ref.watch(
      merkOptionsFamilyProvider(selectedTypeEngineId),
    );
    final selectedId = ref.watch(mguSelectedMerkIdProvider);
    return merkOptions.when(
      data: (options) => DropdownButtonFormField<String>(
        value: selectedId,
        decoration: const InputDecoration(labelText: 'Merk'),
        items: options
            .map(
              (opt) => DropdownMenuItem(
                value: opt.id as String,
                child: Text(opt.name),
              ),
            )
            .toList(),
        onChanged: (value) {
          ref.read(mguSelectedMerkIdProvider.notifier).state = value;
          ref.read(mguSelectedTypeChassisIdProvider.notifier).state = null;
          ref.read(mguSelectedJenisKendaraanIdProvider.notifier).state = null;
          ref.read(mguSelectedVarianBodyIdProvider.notifier).state = null;
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const Text('Error'),
    );
  }

  Widget _buildTypeChassisDropdown() {
    final selectedMerkId = ref.watch(mguSelectedMerkIdProvider);
    final typeChassisOptions = ref.watch(
      typeChassisOptionsFamilyProvider(selectedMerkId),
    );
    final selectedId = ref.watch(mguSelectedTypeChassisIdProvider);
    return typeChassisOptions.when(
      data: (options) => DropdownButtonFormField<String>(
        value: selectedId,
        decoration: const InputDecoration(labelText: 'Type Chassis'),
        items: options
            .map(
              (opt) => DropdownMenuItem(
                value: opt.id as String,
                child: Text(opt.name),
              ),
            )
            .toList(),
        onChanged: (value) {
          ref.read(mguSelectedTypeChassisIdProvider.notifier).state = value;
          ref.read(mguSelectedJenisKendaraanIdProvider.notifier).state = null;
          ref.read(mguSelectedVarianBodyIdProvider.notifier).state = null;
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const Text('Error'),
    );
  }

  Widget _buildJenisKendaraanDropdown() {
    final selectedTypeChassisId = ref.watch(mguSelectedTypeChassisIdProvider);
    final jenisKendaraanOptions = ref.watch(
      jenisKendaraanOptionsFamilyProvider(selectedTypeChassisId),
    );
    final selectedId = ref.watch(mguSelectedJenisKendaraanIdProvider);
    return jenisKendaraanOptions.when(
      data: (options) => DropdownButtonFormField<String>(
        value: selectedId,
        decoration: const InputDecoration(labelText: 'Jenis Kendaraan'),
        items: options
            .map(
              (opt) => DropdownMenuItem(
                value: opt.id as String,
                child: Text(opt.name),
              ),
            )
            .toList(),
        onChanged: (value) {
          ref.read(mguSelectedJenisKendaraanIdProvider.notifier).state = value;
          ref.read(mguSelectedVarianBodyIdProvider.notifier).state = null;
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const Text('Error'),
    );
  }

  Widget _buildVarianBodyDropdown() {
    final selectedJenisKendaraanId = ref.watch(
      mguSelectedJenisKendaraanIdProvider,
    );
    final varianBodyOptions = ref.watch(
      varianBodyOptionsFamilyProvider(selectedJenisKendaraanId),
    );
    final selectedId = ref.watch(mguSelectedVarianBodyIdProvider);

    return varianBodyOptions.when(
      data: (options) => DropdownButtonFormField<int>(
        value: selectedId,
        decoration: const InputDecoration(labelText: 'Varian Body'),
        items: options
            .map(
              (opt) => DropdownMenuItem<int>(
                value: opt.id, // langsung int
                child: Text(opt.name),
              ),
            )
            .toList(),
        onChanged: (value) {
          ref.read(mguSelectedVarianBodyIdProvider.notifier).state = value;
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const Text('Error'),
    );
  }
}
