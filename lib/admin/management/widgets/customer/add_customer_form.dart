import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart'; // <-- Import package
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/management/providers/customer_providers.dart';
import 'package:master_gambar/admin/management/repository/customer_repository.dart';

class AddCustomerForm extends ConsumerStatefulWidget {
  const AddCustomerForm({super.key});
  @override
  ConsumerState<AddCustomerForm> createState() => _AddCustomerFormState();
}

class _AddCustomerFormState extends ConsumerState<AddCustomerForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaPtController = TextEditingController();
  final _pjController = TextEditingController();
  File? _signatureFile;
  bool _isLoading = false;
  bool _isDragging = false; // State untuk feedback visual

  @override
  void dispose() {
    _namaPtController.dispose();
    _pjController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        _signatureFile = File(result.files.single.path!);
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
        );

        if (_signatureFile != null) {
          await repo.uploadSignature(
            customerId: newCustomer.id,
            signatureFile: _signatureFile!,
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
        setState(() => _signatureFile = null);
        ref.invalidate(customerListProvider);
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _namaPtController,
                  decoration: const InputDecoration(labelText: 'Nama Customer'),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _pjController,
                  decoration: const InputDecoration(
                    labelText: 'Penanggung Jawab',
                  ),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Paraf', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    // --- BUNGKUS DENGAN DROPTARGET ---
                    DropTarget(
                      onDragDone: (details) {
                        if (details.files.isNotEmpty) {
                          setState(() {
                            _signatureFile = File(details.files.first.path);
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
                              decoration: const BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: Colors.grey),
                                ),
                              ),
                              child: _signatureFile != null
                                  ? Image.file(
                                      _signatureFile!,
                                      fit: BoxFit.contain,
                                    )
                                  : const Center(
                                      child: Text(
                                        'PNG',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Pilih Gambar'),
                              onPressed: _pickImage,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Text(
                      'Saran lebar gambar ± 500px',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Customer'),
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
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
