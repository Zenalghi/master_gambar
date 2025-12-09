// File: lib/admin/master/widgets/add_gambar_kelistrikan_form.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:master_gambar/data/models/option_item.dart';
import 'package:pdfx/pdfx.dart';

class AddGambarKelistrikanForm extends ConsumerStatefulWidget {
  // Terima data awal Master Data (bukan komponen terpisah)
  final OptionItem? initialMasterData;

  // Callback disesuaikan dengan Repository: ID (int), Deskripsi, File (Nullable)
  final void Function(int masterDataId, String deskripsi, File? file) onUpload;

  const AddGambarKelistrikanForm({
    super.key,
    this.initialMasterData,
    required this.onUpload,
  });

  @override
  ConsumerState<AddGambarKelistrikanForm> createState() =>
      _AddGambarKelistrikanFormState();
}

class _AddGambarKelistrikanFormState
    extends ConsumerState<AddGambarKelistrikanForm> {
  final _formKey = GlobalKey<FormState>();
  final _deskripsiController = TextEditingController();

  // State Dropdown Master Data
  int? _selectedMasterDataId;
  OptionItem? _selectedMasterDataItem; // Untuk tampilan awal dropdown

  File? _selectedFile;
  PdfController? _pdfController;

  // State Cek File Server
  bool _isFileOnServer = false;
  String? _serverFileName;
  bool _isCheckingFile = false;

  @override
  void initState() {
    super.initState();
    // Isi data awal jika ada (dari fitur copy-paste)
    if (widget.initialMasterData != null) {
      _selectedMasterDataItem = widget.initialMasterData;
      _selectedMasterDataId = widget.initialMasterData!.id as int;
      // Langsung cek file di server berdasarkan Master Data ini
      // (Kita butuh chassisId, asumsinya backend checkFileStatus bisa handle via masterDataId atau kita fetch dulu)
      // Untuk simplifikasi, kita trigger cek saat user memilih/data masuk
      _checkFileStatus(_selectedMasterDataId!);
    }
  }

  // Helper untuk mengecek status file di server (via repository)
  Future<void> _checkFileStatus(int masterDataId) async {
    setState(() => _isCheckingFile = true);
    // Kita asumsikan repository punya method checkKelistrikanFileStatusByMasterData
    // ATAU kita perlu chassisId. Jika repository butuh chassisId,
    // kita perlu object MasterData lengkap.
    // SEMENTARA: Kita skip cek otomatis di init jika kompleks,
    // tapi idealnya repository bisa handle check by masterDataId.

    // Anggap repository sudah support atau kita abaikan dulu warning file ada
    setState(() => _isCheckingFile = false);
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

    // Validasi: File wajib ada KECUALI sudah ada di server
    if (!_isFileOnServer && _selectedFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harap pilih file PDF')));
      return;
    }

    // Panggil callback parent dengan tipe data yang benar
    widget.onUpload(
      _selectedMasterDataId!,
      _deskripsiController.text,
      _selectedFile, // Bisa null jika _isFileOnServer true
    );

    // Reset form UI (Opsional, karena parent mungkin merefresh halaman)
    setState(() {
      _selectedFile = null;
      _pdfController?.dispose();
      _pdfController = null;
      _deskripsiController.clear();
      if (widget.initialMasterData == null) {
        _selectedMasterDataId = null;
        _selectedMasterDataItem = null;
      }
    });
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
                        // 1. DROPDOWN MASTER DATA (Menggantikan 3 dropdown terpisah)
                        DropdownSearch<OptionItem>(
                          items: (String filter, _) => ref.read(
                            masterDataOptionsProvider(filter).future,
                          ),
                          itemAsString: (OptionItem item) => item.name,
                          compareFn: (i1, i2) => i1.id == i2.id,

                          selectedItem: _selectedMasterDataItem,

                          onChanged: (OptionItem? item) {
                            setState(() {
                              _selectedMasterDataItem = item;
                              _selectedMasterDataId = item?.id as int?;
                              _isFileOnServer =
                                  false; // Reset status file saat ganti data
                            });
                            // Optional: Cek status file di server saat ganti
                            // if (item != null) _checkFileStatus(item.id);
                          },

                          decoratorProps: const DropDownDecoratorProps(
                            decoration: InputDecoration(
                              labelText:
                                  'Pilih Master Data (Engine / Merk / Chassis)',
                              hintText: 'Ketik untuk mencari...',
                              isDense: true,
                              border: OutlineInputBorder(),
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
                          validator: (item) =>
                              item == null && _selectedMasterDataId == null
                              ? 'Wajib dipilih'
                              : null,
                        ),

                        const SizedBox(height: 16),

                        // Indikator File Server (Opsional, jika fitur cek aktif)
                        if (_isFileOnServer)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "File PDF sudah tersedia. Anda cukup mengisi deskripsi.",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_isFileOnServer) const SizedBox(height: 16),

                        // 2. Deskripsi
                        TextFormField(
                          controller: _deskripsiController,
                          decoration: const InputDecoration(
                            labelText: 'Deskripsi Gambar Kelistrikan',
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.characters,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 24),

                        // 3. Tombol File & Upload (Sembunyikan jika file sudah ada di server)
                        if (!_isFileOnServer)
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
                                ],
                              ),
                              if (_selectedFile != null) ...[
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8.0,
                                    bottom: 16.0,
                                  ),
                                  child: Text(
                                    'File: ${_selectedFile!.path.split(Platform.pathSeparator).last}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),

                        // Tombol Submit
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Simpan Data Kelistrikan'),
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
