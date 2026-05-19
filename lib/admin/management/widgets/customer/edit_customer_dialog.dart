// lib/admin/management/widgets/customer/edit_customer_dialog.dart
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

  // Controllers
  late final TextEditingController _namaPtController;
  late final TextEditingController _pjController;
  late final TextEditingController _namaDrafterController;
  late final TextEditingController _namaPemeriksaController;

  // Files
  File? _signaturePjFile;
  File? _signatureDrafterFile;
  File? _signaturePemeriksaFile;

  // Drag States
  bool _isDraggingPj = false;
  bool _isDraggingDrafter = false;
  bool _isDraggingPemeriksa = false;

  bool _isLoading = false;
  String? _authToken;
  late Customer _currentCustomer;

  @override
  void initState() {
    super.initState();
    _currentCustomer = widget.customer;
    _namaPtController = TextEditingController(text: _currentCustomer.namaPt);
    _pjController = TextEditingController(text: _currentCustomer.pj);
    _namaDrafterController = TextEditingController(
      text: _currentCustomer.namaDrafter ?? '',
    );
    _namaPemeriksaController = TextEditingController(
      text: _currentCustomer.namaPemeriksa ?? '',
    );
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
    _namaDrafterController.dispose();
    _namaPemeriksaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        if (type == 'pj') _signaturePjFile = File(result.files.single.path!);
        if (type == 'drafter')
          _signatureDrafterFile = File(result.files.single.path!);
        if (type == 'pemeriksa')
          _signaturePemeriksaFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final repo = ref.read(customerRepositoryProvider);

        // Update Text Data
        Customer updatedCustomer = await repo.updateCustomer(
          id: _currentCustomer.id,
          namaPt: _namaPtController.text,
          pj: _pjController.text,
          namaDrafter: _namaDrafterController.text,
          namaPemeriksa: _namaPemeriksaController.text,
        );

        // Upload files if changed
        if (_signaturePjFile != null) {
          updatedCustomer = await repo.uploadSignature(
            customerId: _currentCustomer.id,
            signatureFile: _signaturePjFile!,
          );
        }
        if (_signatureDrafterFile != null) {
          updatedCustomer = await repo.uploadSignatureDrafter(
            customerId: _currentCustomer.id,
            signatureFile: _signatureDrafterFile!,
          );
        }
        if (_signaturePemeriksaFile != null) {
          updatedCustomer = await repo.uploadSignaturePemeriksa(
            customerId: _currentCustomer.id,
            signatureFile: _signaturePemeriksaFile!,
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer berhasil diupdate!'),
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
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // (Method _submitDelete tetap sama seperti sebelumnya)
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

  Widget _buildParafUpload({
    required String label,
    required File? currentFile,
    required String? imageUrl,
    required bool isDragging,
    required Function(File) onFileDropped,
    required Function(bool) onDragUpdate,
    required VoidCallback onPick,
    required String? signatureKey,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            DropTarget(
              onDragDone: (details) {
                if (details.files.isNotEmpty)
                  onFileDropped(File(details.files.first.path));
              },
              onDragEntered: (_) => onDragUpdate(true),
              onDragExited: (_) => onDragUpdate(false),
              child: Container(
                width: 100,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDragging
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    width: isDragging ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: currentFile != null
                    ? Image.file(currentFile, fit: BoxFit.contain)
                    : (imageUrl != null
                          ? Image.network(
                              imageUrl,
                              key: ValueKey(signatureKey),
                              fit: BoxFit.contain,
                              headers: {'Authorization': 'Bearer $_authToken'},
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                  ),
                            )
                          : const Center(
                              child: Text(
                                'PNG',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            )),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file, size: 16),
              label: const Text('Ganti Gambar'),
              onPressed: onPick,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = ref.read(apiClientProvider).dio.options.baseUrl;
    final timestamp = _currentCustomer.updatedAt.millisecondsSinceEpoch;

    final pjImageUrl =
        (_authToken != null && _currentCustomer.signaturePj != null)
        ? '$baseUrl/admin/customers/${_currentCustomer.id}/paraf?v=$timestamp'
        : null;
    final drafterImageUrl =
        (_authToken != null && _currentCustomer.signatureDrafter != null)
        ? '$baseUrl/admin/customers/${_currentCustomer.id}/paraf-drafter?v=$timestamp'
        : null;
    final pemeriksaImageUrl =
        (_authToken != null && _currentCustomer.signaturePemeriksa != null)
        ? '$baseUrl/admin/customers/${_currentCustomer.id}/paraf-pemeriksa?v=$timestamp'
        : null;

    return AlertDialog(
      title: Text(
        'Edit Customer: ${_currentCustomer.namaPt}',
        style: const TextStyle(fontSize: 21),
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            // Ditambahkan agar bisa scroll
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _namaPtController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Customer (PT)',
                  ),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // --- SECTION PJ ---
                TextFormField(
                  controller: _pjController,
                  decoration: const InputDecoration(
                    labelText: 'Penanggung Jawab (PJ)',
                  ),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 8),
                _buildParafUpload(
                  label: 'Paraf PJ',
                  currentFile: _signaturePjFile,
                  imageUrl: pjImageUrl,
                  isDragging: _isDraggingPj,
                  onFileDropped: (f) => setState(() => _signaturePjFile = f),
                  onDragUpdate: (val) => setState(() => _isDraggingPj = val),
                  onPick: () => _pickImage('pj'),
                  signatureKey: _currentCustomer.signaturePj,
                ),
                const Divider(height: 32),

                // --- SECTION DRAFTER ---
                TextFormField(
                  controller: _namaDrafterController,
                  decoration: const InputDecoration(labelText: 'Nama Drafter'),
                ),
                const SizedBox(height: 8),
                _buildParafUpload(
                  label: 'Paraf Drafter',
                  currentFile: _signatureDrafterFile,
                  imageUrl: drafterImageUrl,
                  isDragging: _isDraggingDrafter,
                  onFileDropped: (f) =>
                      setState(() => _signatureDrafterFile = f),
                  onDragUpdate: (val) =>
                      setState(() => _isDraggingDrafter = val),
                  onPick: () => _pickImage('drafter'),
                  signatureKey: _currentCustomer.signatureDrafter,
                ),
                const Divider(height: 32),

                // --- SECTION PEMERIKSA ---
                TextFormField(
                  controller: _namaPemeriksaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Pemeriksa',
                  ),
                ),
                const SizedBox(height: 8),
                _buildParafUpload(
                  label: 'Paraf Pemeriksa',
                  currentFile: _signaturePemeriksaFile,
                  imageUrl: pemeriksaImageUrl,
                  isDragging: _isDraggingPemeriksa,
                  onFileDropped: (f) =>
                      setState(() => _signaturePemeriksaFile = f),
                  onDragUpdate: (val) =>
                      setState(() => _isDraggingPemeriksa = val),
                  onPick: () => _pickImage('pemeriksa'),
                  signatureKey: _currentCustomer.signaturePemeriksa,
                ),

                const SizedBox(height: 16),
                const Text(
                  'Saran lebar gambar ± 500px (Format PNG)',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (_isLoading) const CircularProgressIndicator(),
        TextButton(
          onPressed: _isLoading ? null : _submitDelete,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Hapus'),
        ),
        const SizedBox(width: 200),
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
