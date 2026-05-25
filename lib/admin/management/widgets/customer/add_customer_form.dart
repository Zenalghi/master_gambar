import 'dart:io';
import 'dart:typed_data';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/customer_providers.dart';
import '../../repository/customer_repository.dart';

class AddCustomerForm extends ConsumerStatefulWidget {
  const AddCustomerForm({super.key});
  @override
  ConsumerState<AddCustomerForm> createState() => _AddCustomerFormState();
}

class _AddCustomerFormState extends ConsumerState<AddCustomerForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaPtController = TextEditingController();
  final _pjController = TextEditingController();
  final _drafterController = TextEditingController();
  final _pemeriksaController = TextEditingController();

  // 1. Ubah definisi state File menjadi Uint8List dan String (untuk nama)
  Uint8List? _signatureBytespj;
  String? _signatureNamepj;

  Uint8List? _signatureBytesdrafter;
  String? _signatureNamedrafter;

  Uint8List? _signatureBytespemeriksa;
  String? _signatureNamepemeriksa;
  bool _isLoading = false;
  bool _isDragging = false; // State untuk feedback visual

  @override
  void dispose() {
    _namaPtController.dispose();
    _pjController.dispose();
    _drafterController.dispose();
    _pemeriksaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // WAJIB TRUE AGAR JALAN DI WEB
    );

    if (result != null) {
      final file = result.files.single;

      // Ambil bytes. Gunakan fallback path jika bytes kosong (biasanya aman untuk Desktop)
      Uint8List? fileBytes = file.bytes;
      if (fileBytes == null && !kIsWeb && file.path != null) {
        fileBytes = File(file.path!).readAsBytesSync();
      }

      if (fileBytes != null) {
        setState(() {
          if (type == 'pj') {
            _signatureBytespj = fileBytes;
            _signatureNamepj = file.name;
          }
          if (type == 'drafter') {
            _signatureBytesdrafter = fileBytes;
            _signatureNamedrafter = file.name;
          }
          if (type == 'pemeriksa') {
            _signatureBytespemeriksa = fileBytes;
            _signatureNamepemeriksa = file.name;
          }
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final repo = ref.read(customerRepositoryProvider);
        final newCustomer = await repo.addCustomer(
          namaPt: _namaPtController.text,
          pj: _pjController.text,
          namaDrafter: _drafterController.text.isNotEmpty
              ? _drafterController.text
              : null,
          namaPemeriksa: _pemeriksaController.text.isNotEmpty
              ? _pemeriksaController.text
              : null,
        );

        if (_signatureBytespj != null) {
          await repo.uploadSignature(
            customerId: newCustomer.id,
            bytes: _signatureBytespj!,
            fileName: _signatureNamepj ?? 'paraf_pj.png',
          );
        }
        if (_signatureBytesdrafter != null) {
          await repo.uploadSignatureDrafter(
            customerId: newCustomer.id,
            bytes: _signatureBytesdrafter!,
            fileName: _signatureNamedrafter ?? 'paraf_drafter.png',
          );
        }
        if (_signatureBytespemeriksa != null) {
          await repo.uploadSignaturePemeriksa(
            customerId: newCustomer.id,
            bytes: _signatureBytespemeriksa!,
            fileName: _signatureNamepemeriksa ?? 'paraf_pemeriksa.png',
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
        _formKey.currentState?.reset();
        _namaPtController.clear();
        _pjController.clear();
        _drafterController.clear();
        _pemeriksaController.clear();
        setState(() => _signatureBytespj = null);
        setState(() => _signatureBytesdrafter = null);
        setState(() => _signatureBytespemeriksa = null);
        ref.read(customerInvalidator.notifier).state++;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _namaPtController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Customer',
                      ),
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _drafterController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Drafter (Opsional)',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _pjController,
                      decoration: const InputDecoration(
                        labelText: 'Penanggung Jawab',
                      ),
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _pemeriksaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Pemeriksa (Opsional)',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Paraf PJ', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    // --- BUNGKUS DENGAN DROPTARGET ---
                    Row(
                      children: [
                        DropTarget(
                          onDragDone: (details) async {
                            if (details.files.isNotEmpty) {
                              final file = details.files.first;
                              final bytes = await file
                                  .readAsBytes(); // Mendukung Web dan Desktop
                              setState(() {
                                _signatureBytespj = bytes;
                                _signatureNamepj = file.name;
                              });
                            }
                          },
                          onDragEntered: (details) =>
                              setState(() => _isDragging = true),
                          onDragExited: (details) =>
                              setState(() => _isDragging = false),
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLow,
                              border: Border.all(
                                color: _isDragging
                                    ? colorScheme.primary
                                    : colorScheme.outline,
                                width: _isDragging ? 3 : 1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 100,
                                  height: 50,
                                  child: _signatureBytespj != null
                                      ? Image.memory(
                                          _signatureBytespj!,
                                          fit: BoxFit.contain,
                                          color: colorScheme.onSurface,
                                          colorBlendMode: BlendMode.srcIn,
                                        )
                                      : Center(
                                          child: Text(
                                            'PNG',
                                            style: TextStyle(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Pilih Gambar'),
                          onPressed: () => _pickImage('pj'),
                        ),
                      ],
                    ),
                    const Text(
                      'Saran lebar gambar ± 500px',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Paraf Drafter', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    // --- BUNGKUS DENGAN DROPTARGET ---
                    Row(
                      children: [
                        DropTarget(
                          onDragDone: (details) async {
                            if (details.files.isNotEmpty) {
                              final file = details.files.first;
                              final bytes = await file
                                  .readAsBytes(); // Mendukung Web dan Desktop
                              setState(() {
                                _signatureBytesdrafter = bytes;
                                _signatureNamedrafter = file.name;
                              });
                            }
                          },
                          onDragEntered: (details) =>
                              setState(() => _isDragging = true),
                          onDragExited: (details) =>
                              setState(() => _isDragging = false),
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLow,
                              border: Border.all(
                                color: _isDragging
                                    ? colorScheme.primary
                                    : colorScheme.outline,
                                width: _isDragging ? 3 : 1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 100,
                                  height: 50,
                                  child: _signatureBytesdrafter != null
                                      ? Image.memory(
                                          _signatureBytesdrafter!,
                                          fit: BoxFit.contain,
                                          color: colorScheme.onSurface,
                                          colorBlendMode: BlendMode.srcIn,
                                        )
                                      : Center(
                                          child: Text(
                                            'PNG',
                                            style: TextStyle(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Pilih Gambar'),
                          onPressed: () => _pickImage('drafter'),
                        ),
                      ],
                    ),
                    const Text(
                      'Saran lebar gambar ± 500px',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paraf Pemeriksa',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    // --- BUNGKUS DENGAN DROPTARGET ---
                    Row(
                      children: [
                        DropTarget(
                          onDragDone: (details) async {
                            if (details.files.isNotEmpty) {
                              final file = details.files.first;
                              final bytes = await file
                                  .readAsBytes(); // Mendukung Web dan Desktop
                              setState(() {
                                _signatureBytespemeriksa = bytes;
                                _signatureNamepemeriksa = file.name;
                              });
                            }
                          },
                          onDragEntered: (details) =>
                              setState(() => _isDragging = true),
                          onDragExited: (details) =>
                              setState(() => _isDragging = false),
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLow,
                              border: Border.all(
                                color: _isDragging
                                    ? colorScheme.primary
                                    : colorScheme.outline,
                                width: _isDragging ? 3 : 1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 100,
                                  height: 50,
                                  child: _signatureBytespemeriksa != null
                                      ? Image.memory(
                                          _signatureBytespemeriksa!,
                                          fit: BoxFit.contain,
                                          color: colorScheme.onSurface,
                                          colorBlendMode: BlendMode.srcIn,
                                        )
                                      : Center(
                                          child: Text(
                                            'PNG',
                                            style: TextStyle(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Pilih Gambar'),
                          onPressed: () => _pickImage('pemeriksa'),
                        ),
                      ],
                    ),
                    const Text(
                      'Saran lebar gambar ± 500px',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 80,
                child: VerticalDivider(
                  color: Color(0xFF0D47A1),
                  thickness: 1,
                  width: 20,
                ),
              ),
              const SizedBox(width: 8),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Tambah\nCustomer',
                        textAlign: TextAlign.center,
                      ),
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 10,
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
