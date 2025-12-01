import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/management/providers/customer_providers.dart';
import 'package:master_gambar/admin/management/repository/customer_repository.dart';
import 'package:master_gambar/data/models/customer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/core/providers.dart';

class EditCustomerDialog extends ConsumerStatefulWidget {
  final Customer customer;
  const EditCustomerDialog({super.key, required this.customer});

  @override
  ConsumerState<EditCustomerDialog> createState() => _EditCustomerDialogState();
}

class _EditCustomerDialogState extends ConsumerState<EditCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaPtController;
  late final TextEditingController _pjController;
  File? _signatureFile;
  bool _isLoading = false;
  bool _isDragging = false;
  String? _authToken;
  late Customer _currentCustomer;

  @override
  void initState() {
    super.initState();
    _currentCustomer = widget.customer;
    _namaPtController = TextEditingController(text: _currentCustomer.namaPt);
    _pjController = TextEditingController(text: _currentCustomer.pj);
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _authToken = prefs.getString('auth_token');
    });
  }

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

  Future<void> _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final repo = ref.read(customerRepositoryProvider);

        final updatedCustomer = await repo.updateCustomer(
          id: _currentCustomer.id,
          namaPt: _namaPtController.text,
          pj: _pjController.text,
        );

        setState(() {
          _currentCustomer = updatedCustomer;
        });

        if (_signatureFile != null) {
          final customerWithNewSignature = await repo.uploadSignature(
            customerId: _currentCustomer.id,
            signatureFile: _signatureFile!,
          );
          setState(() {
            _currentCustomer = customerWithNewSignature;
            _signatureFile = null;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer berhasil diupdate!'),
            backgroundColor: Colors.green,
          ),
        );
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

  Future<void> _submitDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Anda yakin ingin menghapus customer: ${widget.customer.namaPt}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(customerRepositoryProvider)
            .deleteCustomer(id: widget.customer.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(customerInvalidator.notifier).state++;
        Navigator.of(context).pop();
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
    final baseUrl = ref.read(apiClientProvider).dio.options.baseUrl;
    final imageUrl =
        (_authToken != null && _currentCustomer.signaturePj != null)
        ? '$baseUrl/admin/customers/${_currentCustomer.id}/paraf?v=${_currentCustomer.updatedAt.millisecondsSinceEpoch}'
        : null;
    return AlertDialog(
      title: Text(
        'Edit Customer: ${_currentCustomer.namaPt}',
        style: TextStyle(fontSize: 21),
      ),

      // --- PERUBAHAN DI SINI ---
      content: SizedBox(
        width: 500,
        // Hapus 'height: 225'
        child: Form(
          key: _formKey,
          // Hapus 'SingleChildScrollView'
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Biarkan Column yang mengatur tinggi
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _namaPtController,
                decoration: const InputDecoration(labelText: 'Nama Customer'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pjController,
                decoration: const InputDecoration(
                  labelText: 'Penanggung Jawab',
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              const Text('Paraf', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Row(
                children: [
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
                      width: 100,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _isDragging
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          width: _isDragging ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _signatureFile != null
                          ? Image.file(_signatureFile!, fit: BoxFit.contain)
                          : (imageUrl != null
                                ? Image.network(
                                    imageUrl,
                                    key: ValueKey(_currentCustomer.signaturePj),
                                    fit: BoxFit.contain,
                                    headers: {
                                      'Authorization': 'Bearer $_authToken',
                                    },
                                    loadingBuilder: (context, child, progress) {
                                      return progress == null
                                          ? child
                                          : const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                      );
                                    },
                                  )
                                : const Center(
                                    child: Text(
                                      'PNG',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Ganti Gambar'),
                    onPressed: _pickImage,
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
      ),
      // --- AKHIR PERUBAHAN ---
      actions: [
        if (_isLoading) const CircularProgressIndicator(),
        TextButton(
          onPressed: _isLoading ? null : _submitDelete,
          child: const Text('Hapus'),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
        ),
        SizedBox(width: 200),
        if (_isLoading) const CircularProgressIndicator(),
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitUpdate,
          child: const Text('Update Customer'),
        ),
      ],
    );
  }
}
