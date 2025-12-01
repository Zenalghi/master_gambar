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
        padding: const EdgeInsets.all(
          10,
        ), // Padding sedikit diperbesar agar rapi
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // BAGIAN UTAMA: KIRI (INPUTS) vs KANAN (GAMBAR)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SISI KIRI: INPUT FIELDS ---
                  // Saya ubah Flex-nya menjadi 3 agar input field mengecil
                  // dan memberi ruang lebih untuk sisi kanan.
                  Expanded(
                    flex: 3,
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

                  // --- SISI KANAN: GAMBAR PARAF ---
                  // Flex: 1 (Rasio 3:1 cukup ideal untuk side-by-side)
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const Text(
                        //   'Paraf',
                        //   style: TextStyle(
                        //     fontSize: 12,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        // const SizedBox(height: 8),

                        // Layout Horizontal: Preview di kiri, Tombol di kanan
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // KOTAK PREVIEW
                            Expanded(
                              child: DropTarget(
                                onDragDone: (details) {
                                  if (details.files.isNotEmpty) {
                                    setState(() {
                                      _signatureFile = File(
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
                                  height: 80, // Tinggi tetap
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
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // TOMBOL PILIH GAMBAR (Ukuran sedang, di sebelah kanan)
                            SizedBox(
                              height: 80, // Samakan tinggi dengan kotak preview
                              width: 80, // Lebar secukupnya
                              child: ElevatedButton(
                                onPressed: _pickImage,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      EdgeInsets.zero, // Biar icon & text muat
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.upload_file, size: 24),
                                    SizedBox(height: 4),
                                    Text(
                                      'Pilih',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // TOMBOL SUBMIT
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
