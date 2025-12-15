// File: lib/admin/master/widgets/kelistrikan_deskripsi_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/models/master_data.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:dio/dio.dart';

class KelistrikanDeskripsiDialog extends ConsumerStatefulWidget {
  final MasterData masterData;

  const KelistrikanDeskripsiDialog({super.key, required this.masterData});

  @override
  ConsumerState<KelistrikanDeskripsiDialog> createState() =>
      _KelistrikanDeskripsiDialogState();
}

class _KelistrikanDeskripsiDialogState
    extends ConsumerState<KelistrikanDeskripsiDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Jika sudah ada deskripsi, isi controller
    _controller = TextEditingController(
      text: widget.masterData.kelistrikanDeskripsi ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Panggil repository untuk simpan deskripsi
      await ref
          .read(masterDataRepositoryProvider)
          .saveDeskripsiKelistrikan(
            masterDataId: widget.masterData.id,
            deskripsi: _controller.text,
          );

      // Refresh tabel Master Data
      ref
          .read(masterDataFilterProvider.notifier)
          .update((state) => Map.from(state));

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deskripsi Kelistrikan berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.response?.data['message'] ?? e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Kelistrikan: ${widget.masterData.typeChassis.name}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jenis Kendaraan: ${widget.masterData.jenisKendaraan.name}',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Gambar Kelistrikan',
                hintText:
                    'Contoh : SEBAGAI MOBIL BARANG BAK MUATAN TERTUTUP (BOX NON LOGAM)',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}
