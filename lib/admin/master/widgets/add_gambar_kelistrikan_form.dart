// File: lib/admin/master/widgets/add_gambar_kelistrikan_form.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:pdfx/pdfx.dart';

class AddGambarKelistrikanForm extends ConsumerStatefulWidget {
  // Callback untuk mengirim data yang siap di-upload ke parent widget
  final Function(String typeChassisId, String deskripsi, File file) onUpload;

  const AddGambarKelistrikanForm({super.key, required this.onUpload});

  @override
  ConsumerState<AddGambarKelistrikanForm> createState() =>
      _AddGambarKelistrikanFormState();
}

class _AddGambarKelistrikanFormState
    extends ConsumerState<AddGambarKelistrikanForm> {
  final _formKey = GlobalKey<FormState>();
  final _deskripsiController = TextEditingController();

  // State untuk melacak ID yang dipilih di dropdown
  String? _selectedTypeEngineId;
  String? _selectedMerkId;
  String? _selectedTypeChassisId;

  // State untuk file PDF yang dipilih
  File? _selectedFile;
  PdfController? _pdfController;

  @override
  void dispose() {
    _deskripsiController.dispose();
    _pdfController?.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _pdfController?.dispose();
        _pdfController = PdfController(
          document: PdfDocument.openFile(_selectedFile!.path),
        );
      });
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 450, // Memberikan tinggi tetap untuk area form dan preview
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- KOLOM KIRI: FORM ---
              Expanded(
                flex: 2,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Dropdown Type Engine
                        typeEngineOptions.when(
                          data: (options) => DropdownButtonFormField<String>(
                            value: _selectedTypeEngineId,
                            decoration: const InputDecoration(
                              labelText: 'Type Engine',
                            ),
                            items: options
                                .map(
                                  (opt) => DropdownMenuItem(
                                    value: opt.id,
                                    child: Text(opt.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => setState(() {
                              _selectedTypeEngineId = value;
                              _selectedMerkId = null;
                              _selectedTypeChassisId = null;
                            }),
                            validator: (v) =>
                                v == null ? 'Wajib dipilih' : null,
                          ),
                          loading: () => const CircularProgressIndicator(),
                          error: (e, st) => const Text('Error'),
                        ),
                        const SizedBox(height: 16),

                        // Dropdown Merk
                        merkOptions.when(
                          data: (options) => DropdownButtonFormField<String>(
                            value: _selectedMerkId,
                            decoration: const InputDecoration(
                              labelText: 'Merk',
                            ),
                            items: options
                                .map(
                                  (opt) => DropdownMenuItem(
                                    value: opt.id as String,
                                    child: Text(opt.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => setState(() {
                              _selectedMerkId = value;
                              _selectedTypeChassisId = null;
                            }),
                            validator: (v) =>
                                v == null ? 'Wajib dipilih' : null,
                          ),
                          loading: () => const CircularProgressIndicator(),
                          error: (e, st) => const Text('Error'),
                        ),
                        const SizedBox(height: 16),

                        // Dropdown Type Chassis
                        typeChassisOptions.when(
                          data: (options) => DropdownButtonFormField<String>(
                            value: _selectedTypeChassisId,
                            decoration: const InputDecoration(
                              labelText: 'Type Chassis',
                            ),
                            items: options
                                .map(
                                  (opt) => DropdownMenuItem(
                                    value: opt.id as String,
                                    child: Text(opt.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => setState(() {
                              _selectedTypeChassisId = value;
                            }),
                            validator: (v) =>
                                v == null ? 'Wajib dipilih' : null,
                          ),
                          loading: () => const CircularProgressIndicator(),
                          error: (e, st) => const Text('Error'),
                        ),
                        const SizedBox(height: 16),

                        // Input Deskripsi
                        TextFormField(
                          controller: _deskripsiController,
                          decoration: const InputDecoration(
                            labelText: 'Deskripsi',
                          ),
                          textCapitalization: TextCapitalization.characters,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 24),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.picture_as_pdf),
                                    label: Text(
                                      _selectedFile == null
                                          ? 'Pilih Gambar'
                                          : 'Ganti Gambar',
                                    ),
                                    onPressed: _pickFile,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_selectedFile != null) ...[
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.upload_file),
                                      label: const Text('Upload Gambar'),
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          widget.onUpload(
                                            _selectedTypeChassisId!,
                                            _deskripsiController.text,
                                            _selectedFile!,
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (_selectedFile != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'File: ${_selectedFile!.path.split(Platform.pathSeparator).last}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // --- KOLOM KANAN: PREVIEW PDF ---
              Expanded(
                flex: 3,
                child: Card(
                  elevation: 4.0,
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
      ),
    );
  }
}
