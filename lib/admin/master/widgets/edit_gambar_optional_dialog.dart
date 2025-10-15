// File: lib/admin/master/widgets/edit_gambar_optional_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:master_gambar/admin/master/models/gambar_optional.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';

class EditGambarOptionalDialog extends ConsumerStatefulWidget {
  final GambarOptional gambarOptional;

  const EditGambarOptionalDialog({super.key, required this.gambarOptional});

  @override
  ConsumerState<EditGambarOptionalDialog> createState() =>
      _EditGambarOptionalDialogState();
}

class _EditGambarOptionalDialogState
    extends ConsumerState<EditGambarOptionalDialog> {
  late final TextEditingController _deskripsiController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _deskripsiController = TextEditingController(
      text: widget.gambarOptional.deskripsi,
    );
  }

  @override
  void dispose() {
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref
            .read(masterDataRepositoryProvider)
            .updateGambarOptional(
              id: widget.gambarOptional.id,
              deskripsi: _deskripsiController.text,
            );

        ref.invalidate(gambarOptionalFilterProvider);
        if (mounted) Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deskripsi berhasil diupdate!'),
            backgroundColor: Colors.green,
          ),
        );
      } on DioException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.response?.data['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Deskripsi Gambar Optional'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _deskripsiController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Deskripsi'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Deskripsi tidak boleh kosong';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(onPressed: _submitUpdate, child: const Text('Update')),
      ],
    );
  }
}
