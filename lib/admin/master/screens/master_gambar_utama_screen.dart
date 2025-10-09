import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:pdfx/pdfx.dart';
import '../../../app/core/notifiers/refresh_notifier.dart';
import '../widgets/pilih_file_pdf_card.dart';
import '../widgets/pilih_varian_body_card.dart';

class MasterGambarUtamaScreen extends ConsumerStatefulWidget {
  const MasterGambarUtamaScreen({super.key});
  @override
  ConsumerState<MasterGambarUtamaScreen> createState() =>
      _MasterGambarUtamaScreenState();
}

class _MasterGambarUtamaScreenState
    extends ConsumerState<MasterGambarUtamaScreen> {
  bool _isLoading = false;
  final _deskripsiController = TextEditingController();
  PdfController? _pdfController;

  @override
  void dispose() {
    _deskripsiController.dispose();
    _pdfController?.dispose();
    super.dispose();
  }

  void _resetForm() {
    // Reset semua state provider setelah berhasil
    ref.read(mguSelectedTypeEngineIdProvider.notifier).state = null;
    ref.read(mguSelectedMerkIdProvider.notifier).state = null;
    ref.read(mguSelectedTypeChassisIdProvider.notifier).state = null;
    ref.read(mguSelectedJenisKendaraanIdProvider.notifier).state = null;
    ref.read(mguSelectedVarianBodyIdProvider.notifier).state = null;
    ref.read(mguGambarUtamaFileProvider.notifier).state = null;
    ref.read(mguGambarTeruraiFileProvider.notifier).state = null;
    ref.read(mguGambarKontruksiFileProvider.notifier).state = null;
    // Reset state untuk form dependen
    ref.read(mguShowDependentOptionalProvider.notifier).state = false;
    ref.read(mguDependentFileProvider.notifier).state = null;
    _deskripsiController.clear();
    setState(() {
      _pdfController?.dispose();
      _pdfController = null;
    });
  }

  void _resetAndRefresh() {
    _resetForm();
    ref.invalidate(typeEngineListProvider);
    ref.invalidate(merkOptionsFamilyProvider);
    ref.invalidate(typeChassisOptionsFamilyProvider);
    ref.invalidate(jenisKendaraanOptionsFamilyProvider);
    ref.invalidate(varianBodyOptionsFamilyProvider);
    ref.invalidate(gambarOptionalListProvider);
    ref.read(refreshNotifierProvider.notifier).refresh();
  }

  Future<void> _pickDependentFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      ref.read(mguDependentFileProvider.notifier).state = file;
      setState(() {
        _pdfController?.dispose();
        _pdfController = PdfController(
          document: PdfDocument.openFile(file.path),
        );
      });
    }
  }

  Future<void> _submit() async {
    final selectedVarianBodyId = ref.read(mguSelectedVarianBodyIdProvider);
    final gambarUtamaFile = ref.read(mguGambarUtamaFileProvider);
    final gambarTeruraiFile = ref.read(mguGambarTeruraiFileProvider);
    final gambarKontruksiFile = ref.read(mguGambarKontruksiFileProvider);
    final showDependent = ref.read(mguShowDependentOptionalProvider);
    final dependentFile = ref.read(mguDependentFileProvider);

    // Validasi dasar
    if (selectedVarianBodyId == null ||
        gambarUtamaFile == null ||
        gambarTeruraiFile == null ||
        gambarKontruksiFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harap lengkapi pilihan Varian Body dan 3 file PDF utama.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validasi untuk form dependen jika checkbox dicentang
    if (showDependent &&
        (_deskripsiController.text.isEmpty || dependentFile == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harap isi deskripsi dan pilih file untuk Gambar Optional Dependen.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // --- LANGKAH 1: UPLOAD GAMBAR UTAMA ---
      final gambarUtama = await ref
          .read(masterDataRepositoryProvider)
          .uploadGambarUtama(
            varianBodyId: selectedVarianBodyId,
            gambarUtama: gambarUtamaFile,
            gambarTerurai: gambarTeruraiFile,
            gambarKontruksi: gambarKontruksiFile,
          );

      // --- LANGKAH 2: UPLOAD GAMBAR OPTIONAL DEPENDEN (JIKA ADA) ---
      if (showDependent) {
        await ref
            .read(masterDataRepositoryProvider)
            .addGambarOptional(
              // Parameter diubah sesuai repository baru
              deskripsi: _deskripsiController.text,
              gambarOptionalFile: dependentFile!,
              tipe: 'dependen',
              gambarUtamaId: gambarUtama.id,
              // varianBodyId tidak perlu dikirim, jadi kita hapus
            );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gambar Utama berhasil di-upload!'),
          backgroundColor: Colors.green,
        ),
      );
      _resetForm();
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
    final showDependent = ref.watch(mguShowDependentOptionalProvider);
    final dependentFile = ref.watch(mguDependentFileProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Manajemen Gambar Utama',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
                onPressed: () {
                  _resetAndRefresh();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const PilihVarianBodyCard(),
          // const SizedBox(height: 16),
          const Divider(),

          // --- UI BARU UNTUK GAMBAR OPTIONAL DEPENDEN ---
          CheckboxListTile(
            title: const Text("Tambahkan Gambar Optional Dependen"),
            value: showDependent,
            onChanged: (value) =>
                ref.read(mguShowDependentOptionalProvider.notifier).state =
                    value!,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          if (showDependent)
            Card(
              margin: const EdgeInsets.only(top: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 320,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _deskripsiController,
                              decoration: const InputDecoration(
                                labelText: 'Deskripsi Optional Dependen',
                              ),
                              textCapitalization: TextCapitalization.characters,
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.picture_as_pdf),
                              label: Text(
                                dependentFile == null
                                    ? 'Pilih Gambar Dependen'
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
                      Expanded(
                        child: Card(
                          elevation: 2,
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            color: Colors.grey.shade100,
                            child: _pdfController != null
                                ? PdfView(
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
            ),

          // const SizedBox(height: 16),
          const Divider(),

          // const SizedBox(height: 16),
          PilihFilePdfCard(onSubmit: _submit, isLoading: _isLoading),
        ],
      ),
    );
  }
}
