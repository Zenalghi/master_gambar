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
  // Parameter opsional untuk "Copy Paste" data dari halaman lain
  final OptionItem? initialTypeEngine;
  final OptionItem? initialMerk;
  final OptionItem? initialTypeChassis;

  const AddGambarKelistrikanForm({
    super.key,
    this.initialTypeEngine,
    this.initialMerk,
    this.initialTypeChassis,
    required void Function(
      String typeEngineId,
      String merkId,
      String typeChassisId,
      String deskripsi,
      File file,
    )
    onUpload,
  });

  @override
  ConsumerState<AddGambarKelistrikanForm> createState() =>
      _AddGambarKelistrikanFormState();
}

class _AddGambarKelistrikanFormState
    extends ConsumerState<AddGambarKelistrikanForm> {
  final _formKey = GlobalKey<FormState>();
  final _deskripsiController = TextEditingController();

  // State dropdown
  int? _selectedTypeEngineId;
  int? _selectedMerkId;
  int? _selectedTypeChassisId;

  File? _selectedFile;
  PdfController? _pdfController;

  @override
  void initState() {
    super.initState();
    // Isi data awal jika ada (dari fitur copy-paste)
    if (widget.initialTypeEngine != null) {
      _selectedTypeEngineId = widget.initialTypeEngine!.id as int;
    }
    if (widget.initialMerk != null) {
      _selectedMerkId = widget.initialMerk!.id as int;
    }
    if (widget.initialTypeChassis != null) {
      _selectedTypeChassisId = widget.initialTypeChassis!.id as int;
    }
  }

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

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harap pilih file PDF')));
      return;
    }

    try {
      await ref
          .read(masterDataRepositoryProvider)
          .addGambarKelistrikan(
            typeEngineId: _selectedTypeEngineId.toString(),
            merkId: _selectedMerkId.toString(),
            typeChassisId: _selectedTypeChassisId.toString(),
            deskripsi: _deskripsiController.text,
            gambarKelistrikanFile: _selectedFile!,
          );

      // Reset form setelah sukses
      setState(() {
        // Kita reset semua kecuali jika form dibuka dalam mode "Copy Paste"
        // Tapi untuk amannya reset saja agar user bisa input baru
        _selectedTypeEngineId = null;
        _selectedMerkId = null;
        _selectedTypeChassisId = null;
        _selectedFile = null;
        _pdfController?.dispose();
        _pdfController = null;
        _deskripsiController.clear();
      });

      // Refresh tabel list
      ref
          .read(gambarKelistrikanFilterProvider.notifier)
          .update((state) => Map.from(state));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gambar Kelistrikan berhasil di-upload!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.response?.data['message'] ?? e.message}'),
            backgroundColor: Colors.red,
          ),
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
          height: 550,
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
                        // 1. Type Engine
                        _buildSearchableDropdown(
                          label: 'Type Engine',
                          provider: mdTypeEngineOptionsProvider,
                          // Jika ada initial value, gunakan. Jika tidak, null.
                          initialItem: widget.initialTypeEngine,
                          onChanged: (val) => _selectedTypeEngineId = val?.id,
                        ),
                        const SizedBox(height: 16),

                        // 2. Merk
                        _buildSearchableDropdown(
                          label: 'Merk',
                          provider: mdMerkOptionsProvider,
                          initialItem: widget.initialMerk,
                          onChanged: (val) => _selectedMerkId = val?.id,
                        ),
                        const SizedBox(height: 16),

                        // 3. Type Chassis
                        _buildSearchableDropdown(
                          label: 'Type Chassis',
                          provider: mdTypeChassisOptionsProvider,
                          initialItem: widget.initialTypeChassis,
                          onChanged: (val) => _selectedTypeChassisId = val?.id,
                        ),
                        const SizedBox(height: 16),

                        // 4. Deskripsi
                        TextFormField(
                          controller: _deskripsiController,
                          decoration: const InputDecoration(
                            labelText: 'Deskripsi',
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.characters,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 24),

                        // 5. Tombol File & Upload
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
                                          ? 'Pilih PDF'
                                          : 'Ganti PDF',
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
                                      label: const Text('Upload'),
                                      onPressed: _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
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
      selectedItem: initialItem, // Set nilai awal (penting untuk copy-paste)
      onChanged: onChanged,
      decoratorProps: DropDownDecoratorProps(
        baseStyle: const TextStyle(fontSize: 13, height: 1.0),
        decoration: InputDecoration(
          constraints: const BoxConstraints(maxHeight: 32),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 10,
          ),
          labelStyle: const TextStyle(fontSize: 12),
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: const TextFieldProps(
          style: TextStyle(fontSize: 13, height: 1.0),
          decoration: InputDecoration(
            constraints: BoxConstraints(maxHeight: 32),
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            hintStyle: TextStyle(fontSize: 13, height: 1.0),
            hintText: "Cari...",
            prefixIcon: Icon(Icons.search),
          ),
        ),
        itemBuilder: (context, item, isSelected, isDisabled) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            height:
                30, // Paksa tinggi item menjadi 30px (atau lebih kecil sesuai selera)
            alignment: Alignment.centerLeft,
            child: Text(
              item.name,
              style: TextStyle(
                fontSize: 12,
                height: 1.0,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      validator: (item) => item == null ? 'Wajib dipilih' : null,
    );
  }
}
