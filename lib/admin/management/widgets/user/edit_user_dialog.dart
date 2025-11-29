import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/management/providers/user_providers.dart';
import 'package:master_gambar/admin/management/repository/user_repository.dart';
import 'package:master_gambar/data/models/app_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/core/providers.dart';

class EditUserDialog extends ConsumerStatefulWidget {
  final AppUser user;
  const EditUserDialog({super.key, required this.user});

  @override
  ConsumerState<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends ConsumerState<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  late final TextEditingController _hintController;
  int? _selectedRoleId;
  File? _signatureFile;
  bool _isLoading = false;
  String? _authToken;
  late AppUser _currentUser;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _nameController = TextEditingController(text: _currentUser.name);
    _usernameController = TextEditingController(text: _currentUser.username);
    _hintController = TextEditingController(text: _currentUser.hint);
    _selectedRoleId = _currentUser.role?.id;
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _authToken = prefs.getString('auth_token'));
  }

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

  Future<void> _submitUpdate() async {
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
        final updatedUser = await repo.updateUser(
          id: _currentUser.id,
          name: _nameController.text,
          username: _usernameController.text,
          roleId: _selectedRoleId!,
          password: _passwordController.text.isNotEmpty
              ? _passwordController.text
              : null,
          hint: _hintController.text,
        );
        setState(() => _currentUser = updatedUser);

        if (_signatureFile != null) {
          final userWithNewSignature = await repo.uploadSignature(
            userId: _currentUser.id,
            signatureFile: _signatureFile!,
          );
          setState(() {
            _currentUser = userWithNewSignature;
            _signatureFile = null;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User berhasil diupdate!'),
            backgroundColor: Colors.green,
          ),
        );
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

  Future<void> _submitDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Anda yakin ingin menghapus user: ${_currentUser.name}?'),
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
        await ref.read(userRepositoryProvider).deleteUser(id: _currentUser.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(userInvalidator.notifier).state++;
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

  @override
  Widget build(BuildContext context) {
    final roleOptions = ref.watch(roleOptionsProvider);
    final baseUrl = ref.read(apiClientProvider).dio.options.baseUrl;

    final imageUrl = (_authToken != null && _currentUser.signature != null)
        ? '$baseUrl/admin/users/${_currentUser.id}/paraf?v=${DateTime.now().millisecondsSinceEpoch}'
        : null;

    return AlertDialog(
      title: Text('Edit User: ${_currentUser.name}'),
      content: SizedBox(
        width: 500,
        height: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password Baru (Opsional)',
                  ),
                  obscureText: true,
                  // --- TAMBAHKAN VALIDATOR INI ---
                  validator: (value) {
                    // Hanya validasi jika field tidak kosong
                    if (value != null && value.isNotEmpty && value.length < 8) {
                      return 'Minimal 8 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordConfirmationController,
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi Password Baru',
                  ),
                  obscureText: true,
                  // --- TAMBAHKAN VALIDATOR INI ---
                  validator: (value) {
                    // Hanya validasi jika password utama diisi
                    if (_passwordController.text.isNotEmpty &&
                        value != _passwordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hintController,
                  decoration: const InputDecoration(
                    labelText: 'Hint (Opsional)',
                  ),
                ),
                const SizedBox(height: 16),
                roleOptions.when(
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
                    decoration: const InputDecoration(labelText: 'Role'),
                    validator: (v) => v == null ? 'Wajib diisi' : null,
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => const Text('Gagal memuat role'),
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
                                      key: ValueKey(_currentUser.signature),
                                      fit: BoxFit.contain,
                                      headers: {
                                        'Authorization': 'Bearer $_authToken',
                                      },
                                      errorBuilder: (c, e, st) =>
                                          const Icon(Icons.error),
                                    )
                                  : const Center(child: Text('PNG'))),
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
      ),
      actions: [
        if (_isLoading) const CircularProgressIndicator(),
        TextButton(
          onPressed: _isLoading ? null : _submitDelete,
          child: const Text('Hapus'),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
        ),
        SizedBox(width: 200),
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitUpdate,
          child: const Text('Update User'),
        ),
      ],
    );
  }
}
