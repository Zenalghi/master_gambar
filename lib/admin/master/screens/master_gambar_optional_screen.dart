import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:dio/dio.dart';
import 'package:pdfx/pdfx.dart';

import '../widgets/gambar_optional_table.dart';

class MasterGambarOptionalScreen extends ConsumerStatefulWidget {
  const MasterGambarOptionalScreen({super.key});
  @override
  ConsumerState<MasterGambarOptionalScreen> createState() =>
      _MasterGambarOptionalScreenState();
}

class _MasterGambarOptionalScreenState
    extends ConsumerState<MasterGambarOptionalScreen> {
  // State untuk dropdown
  String? _selectedTypeEngineId;
  String? _selectedMerkId;
  String? _selectedTypeChassisId;
  String? _selectedJenisKendaraanId;
  int? _selectedVarianBodyId;
  // State untuk form
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
    if (_selectedVarianBodyId == null ||
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
            varianBodyId: _selectedVarianBodyId!,
            deskripsi: _deskripsiController.text,
            gambarOptionalFile: _gambarOptionalFile!,
          );
      // Reset form
      setState(() {
        _selectedTypeEngineId = null;
        _selectedMerkId = null;
        _selectedTypeChassisId = null;
        _selectedJenisKendaraanId = null;
        _selectedVarianBodyId = null;
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
    final typeEngineOptions = ref.watch(typeEngineListProvider);
    final merkOptions = ref.watch(
      merkOptionsFamilyProvider(_selectedTypeEngineId),
    );
    final typeChassisOptions = ref.watch(
      typeChassisOptionsFamilyProvider(_selectedMerkId),
    );
    final jenisKendaraanOptions = ref.watch(
      jenisKendaraanOptionsFamilyProvider(_selectedTypeChassisId),
    );
    final varianBodyOptions = ref.watch(
      varianBodyOptionsFamilyProvider(_selectedJenisKendaraanId),
    );

    final isVarianBodySelected = _selectedVarianBodyId != null;
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
          // Widget 1: Form Input
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // ... (Dropdown bertingkat sama seperti Varian Body) ...
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _deskripsiController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Deskripsi Gambar Optional',
                          ),
                          enabled: isVarianBodySelected,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildFilePicker(
                          label: 'Pilih Gambar',
                          file: _gambarOptionalFile,
                          onPressed: isVarianBodySelected ? _pickPdfFile : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            icon: const Icon(Icons.upload),
                            label: const Text('Upload Gambar'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: allFilesSelected ? _submit : null,
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

  Widget _buildFilePicker({
    required String label,
    File? file,
    VoidCallback? onPressed,
  }) {
    return Row(
      children: [
        ElevatedButton(onPressed: onPressed, child: Text(label)),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 120,
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
                      Icons.image_search,
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
