// File: lib/admin/master/widgets/kelistrikan_deskripsi_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/models/master_data.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:dio/dio.dart';

import '../../../app/core/providers.dart';

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
  bool _isLoadingList = false;

  // State untuk List Deskripsi yang sudah ada
  List<dynamic> _existingOptions = [];
  int? _editingId; // Jika null = Mode Tambah Baru

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _fetchExistingOptions();
  }

  // Fetch data list opsi dari API Options (yang sudah kita update di backend)
  Future<void> _fetchExistingOptions() async {
    setState(() => _isLoadingList = true);
    try {
      // Kita pakai endpoint check status yang sudah ada karena dia mereturn list options
      ref.read(masterDataRepositoryProvider);
      // NOTE: Anda perlu memastikan repository punya method ini atau pakai Dio langsung sementara
      // Asumsi kita pakai helper yang ada di repository atau buat baru
      final response = await ref
          .read(apiClientProvider)
          .dio
          .get('/options/kelistrikan-status/${widget.masterData.id}');

      final data = response.data;
      if (data['status_code'] == 'multiple_options') {
        setState(() {
          _existingOptions = data['options'] ?? [];
        });
      } else if (data['status_code'] == 'ready') {
        // Jika cuma 1, masukkan ke list agar bisa diedit/ditambah
        setState(() {
          _existingOptions = [
            {'id': data['selected_id'], 'deskripsi': data['display_text']},
          ];
        });
      }
    } catch (e) {
      debugPrint('Error fetching options: $e');
    } finally {
      if (mounted) setState(() => _isLoadingList = false);
    }
  }

  // TAMBAHKAN FUNGSI DELETE INI
  Future<void> _onDelete(dynamic option) async {
    // Konfirmasi Dulu
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Deskripsi'),
        content: Text('Yakin ingin menghapus "${option['deskripsi']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true); // Pakai loading state yang sama

    try {
      await ref
          .read(masterDataRepositoryProvider)
          .deleteDeskripsiKelistrikan(option['id']);

      // Refresh List setelah delete
      await _fetchExistingOptions();

      // Jika yang dihapus sedang diedit, reset form
      if (_editingId == option['id']) {
        _onResetForm();
      }

      // Update tabel utama (count berubah)
      ref
          .read(masterDataFilterProvider.notifier)
          .update((state) => Map.from(state));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deskripsi berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEdit(dynamic option) {
    setState(() {
      _editingId = option['id'];
      _controller.text = option['deskripsi'];
    });
  }

  void _onResetForm() {
    setState(() {
      _editingId = null;
      _controller.clear();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Panggil repository untuk simpan/update deskripsi
      // Kita perlu update repository agar support parameter 'id' (untuk edit)
      await ref
          .read(masterDataRepositoryProvider)
          .saveDeskripsiKelistrikan(
            masterDataId: widget.masterData.id,
            deskripsi: _controller.text,
            id: _editingId, // Kirim ID jika mode edit
          );

      // Refresh list lokal
      await _fetchExistingOptions();
      _onResetForm(); // Reset form jadi mode tambah

      // Refresh tabel Master Data Utama (agar kolom status terupdate)
      ref
          .read(masterDataFilterProvider.notifier)
          .update((state) => Map.from(state));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil disimpan!'),
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kelistrikan: ${widget.masterData.typeChassis.name}',
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            'Jenis: ${widget.masterData.jenisKendaraan.name}',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
      content: SizedBox(
        width: 500, // Lebar dialog agar list muat
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. LIST OPTION YANG SUDAH ADA
            const Text(
              'Daftar Opsi Tersedia:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (_isLoadingList)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_existingOptions.isEmpty)
              const Text(
                'Belum ada deskripsi. Tambahkan di bawah.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              )
            else
              Container(
                height: 150, // Batasi tinggi list
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _existingOptions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _existingOptions[index];

                    // LOGIKA KONDISIONAL:
                    // Tombol delete hanya muncul jika total opsi lebih dari 1
                    final bool canDelete = _existingOptions.length > 1;

                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.only(left: 16, right: 8),
                      title: SelectableText(item['deskripsi']),

                      // Ubah Trailing jadi Row untuk menampung 2 tombol (Edit & Delete)
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tombol Edit
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.blue,
                            ),
                            tooltip: 'Edit',
                            onPressed: () => _onEdit(item),
                          ),

                          // Tombol Delete (Kondisional)
                          if (canDelete)
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                size: 18,
                                color: Colors.red,
                              ),
                              tooltip: 'Hapus',
                              onPressed: () => _onDelete(item),
                            )
                          else
                            // Opsional: Icon delete disabled (abu-abu) agar user tau ada fiturnya tapi mati
                            const IconButton(
                              icon: Icon(
                                Icons.delete,
                                size: 18,
                                color: Colors.grey,
                              ),
                              onPressed: null,
                              tooltip: 'Minimal harus ada 1 deskripsi',
                            ),
                        ],
                      ),
                      selected: _editingId == item['id'],
                      selectedTileColor: Colors.blue.shade50,
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),
            const Divider(),

            // 2. FORM INPUT (TAMBAH / EDIT)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _editingId == null
                      ? 'Tambah Opsi Baru'
                      : 'Edit Opsi Terpilih',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _editingId == null ? Colors.green : Colors.orange,
                  ),
                ),
                if (_editingId != null)
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('Mode Tambah'),
                    onPressed: _onResetForm,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            Form(
              key: _formKey,
              child: TextFormField(
                controller: _controller,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Isi Deskripsi',
                  hintText:
                      'Contoh: SEBAGAI MOBIL BARANG BAK MUATAN TERTUTUP (REFRIGERATED BOX)',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _controller.clear(),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _submit,
          icon: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(_editingId == null ? Icons.save : Icons.update, size: 16),
          label: Text(_editingId == null ? 'Simpan Baru' : 'Update'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _editingId == null ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }
}
