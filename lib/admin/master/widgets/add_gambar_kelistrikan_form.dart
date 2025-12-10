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
  final OptionItem? initialTypeEngine;
  final OptionItem? initialMerk;
  final OptionItem? initialTypeChassis;

  const AddGambarKelistrikanForm({
    super.key,
    this.initialTypeEngine,
    this.initialMerk,
    this.initialTypeChassis,
  });

  @override
  ConsumerState<AddGambarKelistrikanForm> createState() =>
      _AddGambarKelistrikanFormState();
}

class _AddGambarKelistrikanFormState
    extends ConsumerState<AddGambarKelistrikanForm> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedTypeEngineId;
  int? _selectedMerkId;
  int? _selectedTypeChassisId;

  File? _selectedFile;
  PdfController? _pdfController;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTypeEngine != null)
      _selectedTypeEngineId = widget.initialTypeEngine!.id as int;
    if (widget.initialMerk != null)
      _selectedMerkId = widget.initialMerk!.id as int;
    if (widget.initialTypeChassis != null)
      _selectedTypeChassisId = widget.initialTypeChassis!.id as int;
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

    // Validasi Kelengkapan
    if (_selectedTypeEngineId == null ||
        _selectedMerkId == null ||
        _selectedTypeChassisId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi Engine, Merk, dan Chassis')),
      );
      return;
    }
    if (_selectedFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harap pilih file PDF')));
      return;
    }

    setState(() => _isUploading = true);

    try {
      await ref
          .read(masterDataRepositoryProvider)
          .uploadKelistrikanFile(
            typeEngineId: _selectedTypeEngineId!,
            merkId: _selectedMerkId!,
            typeChassisId: _selectedTypeChassisId!,
            file: _selectedFile!,
          );

      setState(() {
        _selectedFile = null;
        _pdfController?.dispose();
        _pdfController = null;
        // Opsional: Reset dropdown jika bukan mode copy-paste
        if (widget.initialTypeChassis == null) {
          _selectedTypeEngineId = null;
          _selectedMerkId = null;
          _selectedTypeChassisId = null;
        }
      });

      ref
          .read(gambarKelistrikanFilterProvider.notifier)
          .update((state) => Map.from(state));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload Berhasil!'),
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
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 500,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSearchableDropdown(
                          label: 'Type Engine',
                          provider: mdTypeEngineOptionsProvider,
                          initialItem: widget.initialTypeEngine,
                          onChanged: (val) =>
                              _selectedTypeEngineId = val?.id as int?,
                        ),
                        const SizedBox(height: 16),
                        _buildSearchableDropdown(
                          label: 'Merk',
                          provider: mdMerkOptionsProvider,
                          initialItem: widget.initialMerk,
                          onChanged: (val) => _selectedMerkId = val?.id as int?,
                        ),
                        const SizedBox(height: 16),
                        _buildSearchableDropdown(
                          label: 'Type Chassis',
                          provider: mdTypeChassisOptionsProvider,
                          initialItem: widget.initialTypeChassis,
                          onChanged: (val) =>
                              _selectedTypeChassisId = val?.id as int?,
                        ),
                        const SizedBox(height: 24),

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
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        const SizedBox(height: 24),

                        ElevatedButton.icon(
                          icon: _isUploading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.upload_file),
                          label: const Text('Upload File'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _isUploading ? null : _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
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

  Widget _buildSearchableDropdown({
    required String label,
    required FutureProviderFamily<List<OptionItem>, String> provider,
    required Function(OptionItem?) onChanged,
    OptionItem? initialItem,
  }) {
    return DropdownSearch<OptionItem>(
      items: (String filter, _) => ref.read(provider(filter).future),
      itemAsString: (OptionItem item) => item.name,
      compareFn: (i1, i2) => i1.id == i2.id,
      selectedItem: initialItem,
      onChanged: onChanged,
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
      ),
      popupProps: const PopupProps.menu(showSearchBox: true),
      validator: (item) =>
          item == null &&
              (label == 'Type Engine'
                      ? _selectedTypeEngineId
                      : label == 'Merk'
                      ? _selectedMerkId
                      : _selectedTypeChassisId) ==
                  null
          ? 'Wajib dipilih'
          : null,
    );
  }
}
