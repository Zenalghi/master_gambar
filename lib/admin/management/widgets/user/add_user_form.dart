import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/management/providers/user_providers.dart';
import 'package:master_gambar/admin/management/repository/user_repository.dart';

class AddUserForm extends ConsumerStatefulWidget {
  const AddUserForm({super.key});
  @override
  ConsumerState<AddUserForm> createState() => _AddUserFormState();
}

class _AddUserFormState extends ConsumerState<AddUserForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final _hintController = TextEditingController();
  int? _selectedRoleId;
  File? _signatureFile;
  bool _isLoading = false;
  bool _isDragging = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() => _signatureFile = File(result.files.single.path!));
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _passwordConfirmationController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konfirmasi password tidak cocok!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() => _isLoading = true);
      try {
        final repo = ref.read(userRepositoryProvider);
        final newUser = await repo.addUser(
          name: _nameController.text,
          username: _usernameController.text,
          password: _passwordController.text,
          roleId: _selectedRoleId!,
          hint: _hintController.text,
        );

        if (_signatureFile != null) {
          await repo.uploadSignature(
            userId: newUser.id,
            signatureFile: _signatureFile!,
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
        _formKey.currentState?.reset();
        _nameController.clear();
        _usernameController.clear();
        _passwordController.clear();
        _passwordConfirmationController.clear();
        _hintController.clear();
        setState(() {
          _signatureFile = null;
          _selectedRoleId = null;
        });
        ref.read(userInvalidator.notifier).state++;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleOptions = ref.watch(roleOptionsProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // BAGIAN UTAMA: KIRI (INPUTS) vs KANAN (GAMBAR)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SISI KIRI: INPUT FIELDS (FLEX 7) ---
                  Expanded(
                    flex: 10,
                    child: Column(
                      children: [
                        // ROW 1: Nama, Username, Role
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Nama',
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? 'Wajib diisi' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? 'Wajib diisi' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: roleOptions.when(
                                data: (roles) => DropdownButtonFormField<int>(
                                  value: _selectedRoleId,
                                  items: roles
                                      .map(
                                        (role) => DropdownMenuItem<int>(
                                          value: role.id as int,
                                          child: Text(role.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) =>
                                      setState(() => _selectedRoleId = value),
                                  decoration: const InputDecoration(
                                    labelText: 'Role',
                                  ),
                                  validator: (v) =>
                                      v == null ? 'Wajib diisi' : null,
                                ),
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (e, st) =>
                                    const Text('Gagal memuat role'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ROW 2: Password, Konfirm Password, Hint
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _passwordController,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Wajib diisi';
                                  }
                                  if (value.length < 8) {
                                    return 'Min 8 karakter';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _passwordConfirmationController,
                                decoration: const InputDecoration(
                                  labelText: 'Konfirm Password',
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Wajib diisi';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Tidak cocok';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _hintController,
                                decoration: const InputDecoration(
                                  labelText: 'Hint (Opsional)',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // --- SISI KANAN: GAMBAR PARAF (FLEX 2) ---
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        // const Text(
                        //   'Paraf',
                        //   style: TextStyle(
                        //     fontSize: 12,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        const SizedBox(height: 8),
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
                            height: 80, // Tinggi kotak preview
                            width: double.infinity,
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
                                ? Image.file(
                                    _signatureFile!,
                                    fit: BoxFit.contain,
                                  )
                                : const Center(
                                    child: Text(
                                      'Paraf Preview',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.upload_file, size: 16),
                            label: const Text('Pilih Gambar'),
                            onPressed: _pickImage,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // TOMBOL SUBMIT (FULL WIDTH DI BAWAH)
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah User'),
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
