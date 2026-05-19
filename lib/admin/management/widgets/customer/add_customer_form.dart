import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
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

  File? _signatureFilepj;
  File? _signatureFiledrafter;
  File? _signatureFilepemeriksa;
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
    );
    if (result != null) {
      setState(() {
        if (type == 'pj') _signatureFilepj = File(result.files.single.path!);
        if (type == 'drafter')
          _signatureFiledrafter = File(result.files.single.path!);
        if (type == 'pemeriksa')
          _signatureFilepemeriksa = File(result.files.single.path!);
      });
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

        if (_signatureFilepj != null) {
          await repo.uploadSignature(
            customerId: newCustomer.id,
            signatureFile: _signatureFilepj!,
          );
        }
        if (_signatureFiledrafter != null) {
          await repo.uploadSignatureDrafter(
            customerId: newCustomer.id,
            signatureFile: _signatureFiledrafter!,
          );
        }
        if (_signatureFilepemeriksa != null) {
          await repo.uploadSignaturePemeriksa(
            customerId: newCustomer.id,
            signatureFile: _signatureFilepemeriksa!,
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
        setState(() => _signatureFilepj = null);
        setState(() => _signatureFiledrafter = null);
        setState(() => _signatureFilepemeriksa = null);
        ref.read(customerInvalidator.notifier).state++;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
                        labelText: 'Nama Drafter',
                      ),
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
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
                        labelText: 'Nama Pemeriksa',
                      ),
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
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
                          onDragDone: (details) {
                            if (details.files.isNotEmpty) {
                              setState(() {
                                _signatureFilepj = File(
                                  details.files.first.path,
                                );
                              });
                            }
                          },
                          onDragEntered: (details) =>
                              setState(() => _isDragging = true),
                          onDragExited: (details) =>
                              setState(() => _isDragging = false),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _isDragging
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                width: _isDragging ? 3 : 1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 100,
                                  height: 50,
                                  child: _signatureFilepj != null
                                      ? Image.file(
                                          _signatureFilepj!,
                                          fit: BoxFit.contain,
                                        )
                                      : const Center(
                                          child: Text(
                                            'PNG',
                                            style: TextStyle(
                                              color: Colors.grey,
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
                          onDragDone: (details) {
                            if (details.files.isNotEmpty) {
                              setState(() {
                                _signatureFiledrafter = File(
                                  details.files.first.path,
                                );
                              });
                            }
                          },
                          onDragEntered: (details) =>
                              setState(() => _isDragging = true),
                          onDragExited: (details) =>
                              setState(() => _isDragging = false),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _isDragging
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                width: _isDragging ? 3 : 1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 100,
                                  height: 50,
                                  child: _signatureFiledrafter != null
                                      ? Image.file(
                                          _signatureFiledrafter!,
                                          fit: BoxFit.contain,
                                        )
                                      : const Center(
                                          child: Text(
                                            'PNG',
                                            style: TextStyle(
                                              color: Colors.grey,
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
                          onDragDone: (details) {
                            if (details.files.isNotEmpty) {
                              setState(() {
                                _signatureFilepemeriksa = File(
                                  details.files.first.path,
                                );
                              });
                            }
                          },
                          onDragEntered: (details) =>
                              setState(() => _isDragging = true),
                          onDragExited: (details) =>
                              setState(() => _isDragging = false),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _isDragging
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                width: _isDragging ? 3 : 1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 100,
                                  height: 50,
                                  child: _signatureFilepemeriksa != null
                                      ? Image.file(
                                          _signatureFilepemeriksa!,
                                          fit: BoxFit.contain,
                                        )
                                      : const Center(
                                          child: Text(
                                            'PNG',
                                            style: TextStyle(
                                              color: Colors.grey,
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
