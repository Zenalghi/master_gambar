// File: lib/admin/master/widgets/add_gambar_kelistrikan_form.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:master_gambar/data/models/option_item.dart';
import 'package:pdfx/pdfx.dart';

class AddGambarKelistrikanForm extends ConsumerStatefulWidget {
  // Opsional: Jika navigasi dari Master Data membawa data chassis
  final OptionItem? initialTypeChassis;

  const AddGambarKelistrikanForm({super.key, this.initialTypeChassis});

  @override
  ConsumerState<AddGambarKelistrikanForm> createState() =>
      _AddGambarKelistrikanFormState();
}

class _AddGambarKelistrikanFormState
    extends ConsumerState<AddGambarKelistrikanForm> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedTypeChassisId;
  File? _selectedFile;
  PdfController? _pdfController;

  @override
  void initState() {
    super.initState();
    if (widget.initialTypeChassis != null) {
      _selectedTypeChassisId = widget.initialTypeChassis!.id as int;
    }
  }

  @override
  void dispose() {
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

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harap pilih file PDF')));
      return;
    }

    try {
      // Panggil repository upload file fisik
      await ref
          .read(masterDataRepositoryProvider)
          .uploadKelistrikanFile(
            typeChassisId: _selectedTypeChassisId!,
            file: _selectedFile!,
          );

      // Reset form
      setState(() {
        _selectedTypeChassisId = null;
        _selectedFile = null;
        _pdfController?.dispose();
        _pdfController = null;
      });

      // Refresh tabel
      ref
          .read(gambarKelistrikanFilterProvider.notifier)
          .update((state) => Map.from(state));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File Kelistrikan berhasil di-upload!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        final msg = e.response?.data['message'] ?? e.message;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $msg'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 400, // Tinggi disesuaikan
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- FORM ---
              Expanded(
                flex: 2,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Hanya Dropdown Type Chassis
                      _buildSearchableDropdown(
                        label: 'Type Chassis',
                        provider: mdTypeChassisOptionsProvider,
                        initialItem: widget.initialTypeChassis,
                        onChanged: (val) =>
                            _selectedTypeChassisId = val?.id as int?,
                      ),
                      const SizedBox(height: 24),

                      // Tombol File
                      ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: Text(
                          _selectedFile == null ? 'Pilih PDF' : 'Ganti PDF',
                        ),
                        onPressed: _pickFile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      if (_selectedFile != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'File: ${_selectedFile!.path.split(Platform.pathSeparator).last}',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ),

                      const Spacer(),

                      ElevatedButton.icon(
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload File'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // --- PREVIEW ---
              Expanded(
                flex: 3,
                child: Card(
                  elevation: 4.0,
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    color: Colors.grey.shade100,
                    child: _pdfController != null
                        ? PdfView(controller: _pdfController!)
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

  // Helper dropdown (sama seperti sebelumnya)
  Widget _buildSearchableDropdown({
    required String label,
    required FutureProviderFamily<List<OptionItem>, String> provider,
    required Function(OptionItem?) onChanged,
    OptionItem? initialItem,
  }) {
    return DropdownSearch<OptionItem>(
      items: (String filter, _) => ref.read(provider(filter).future),
      itemAsString: (OptionItem item) => item.name,
      compareFn: (item1, item2) => item1.id == item2.id,
      selectedItem: initialItem,
      onChanged: onChanged,
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
      ),
      popupProps: const PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: "Cari...",
            prefixIcon: Icon(Icons.search),
          ),
        ),
      ),
      validator: (item) => item == null ? 'Wajib dipilih' : null,
    );
  }
}
