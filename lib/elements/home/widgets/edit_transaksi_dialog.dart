import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/transaksi.dart';
import 'package:master_gambar/elements/home/providers/transaksi_providers.dart';
import 'package:master_gambar/elements/home/repository/options_repository.dart';

class EditTransaksiDialog extends ConsumerStatefulWidget {
  final Transaksi transaksi;

  const EditTransaksiDialog({super.key, required this.transaksi});

  @override
  ConsumerState<EditTransaksiDialog> createState() =>
      _EditTransaksiDialogState();
}

class _EditTransaksiDialogState extends ConsumerState<EditTransaksiDialog> {
  // State lokal untuk menyimpan ID yang dipilih di form
  late int _selectedCustomerId;
  late String _selectedTypeEngineId;
  late String _selectedMerkId;
  late String _selectedTypeChassisId;
  late String _selectedJenisKendaraanId;
  late int _selectedJenisPengajuanId;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Isi state lokal dengan data awal dari transaksi
    _selectedCustomerId = widget.transaksi.customer.id;
    _selectedTypeEngineId = widget.transaksi.aTypeEngine.id;
    _selectedMerkId = widget.transaksi.bMerk.id;
    _selectedTypeChassisId = widget.transaksi.cTypeChassis.id;
    _selectedJenisKendaraanId = widget.transaksi.dJenisKendaraan.id;
    _selectedJenisPengajuanId = widget.transaksi.fPengajuan.id;
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Anda yakin ingin menghapus transaksi ID: ${widget.transaksi.id}? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Tutup dialog konfirmasi
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Ya, Hapus'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Tutup dialog konfirmasi
                _submitDelete(); // Jalankan fungsi hapus
              },
            ),
          ],
        );
      },
    );
  }

  // --- METHOD BARU UNTUK EKSEKUSI HAPUS ---
  void _submitDelete() async {
    try {
      await ref
          .read(transaksiRepositoryProvider)
          .deleteTransaksi(transaksiId: widget.transaksi.id);

      // Tutup dialog edit
      if (mounted) Navigator.of(context).pop();
      // Refresh tabel
      ref.invalidate(transaksiHistoryProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil dihapus!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus transaksi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Transaksi: ${widget.transaksi.id}'),
      content: SizedBox(
        width: 600, // Beri lebar agar nyaman
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCustomerDropdown(),
                const SizedBox(height: 16),
                _buildTypeEngineDropdown(),
                const SizedBox(height: 16),
                _buildMerkDropdown(),
                const SizedBox(height: 16),
                _buildTypeChassisDropdown(),
                const SizedBox(height: 16),
                _buildJenisKendaraanDropdown(),
                const SizedBox(height: 16),
                _buildJenisPengajuanDropdown(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: _showDeleteConfirmationDialog,
              child: const Text('Hapus'),
            ),
            // Spacer agar tombol lain ke kanan
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            const SizedBox(width: 20), // Spacer horizontal
            ElevatedButton(
              onPressed: _submitUpdate,
              child: const Text('Update Transaksi'),
            ),
          ],
        ),
      ],
    );
  }

  // --- Kumpulan Method untuk Membangun Setiap Dropdown ---

  Widget _buildCustomerDropdown() {
    final options = ref.watch(customerOptionsProvider);
    return options.when(
      data: (items) => DropdownButtonFormField<int>(
        value: _selectedCustomerId,
        items: items
            .map(
              (item) =>
                  DropdownMenuItem<int>(value: item.id, child: Text(item.name)),
            )
            .toList(),
        onChanged: (value) => setState(() => _selectedCustomerId = value!),
        decoration: const InputDecoration(labelText: 'Customer'),
        validator: (val) => val == null ? 'Wajib diisi' : null,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Gagal memuat Customer'),
    );
  }

  Widget _buildTypeEngineDropdown() {
    final options = ref.watch(typeEngineOptionsProvider);
    return options.when(
      data: (items) => DropdownButtonFormField<String>(
        value: _selectedTypeEngineId,
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item.id,
                child: Text(item.name),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() {
          _selectedTypeEngineId = value!;
          // Reset anak-anaknya
          _selectedMerkId = '';
          _selectedTypeChassisId = '';
          _selectedJenisKendaraanId = '';
        }),
        decoration: const InputDecoration(labelText: 'Type Engine'),
        validator: (val) => val == null ? 'Wajib diisi' : null,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Gagal memuat Type Engine'),
    );
  }

  Widget _buildMerkDropdown() {
    // Gunakan provider family dengan state lokal sebagai parameter
    final options = ref.watch(merkOptionsFamilyProvider(_selectedTypeEngineId));
    return options.when(
      data: (items) => DropdownButtonFormField<String>(
        value: items.any((item) => item.id == _selectedMerkId)
            ? _selectedMerkId
            : null,
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item.id,
                child: Text(item.name),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() {
          _selectedMerkId = value!;
          // Reset anak-anaknya
          _selectedTypeChassisId = '';
          _selectedJenisKendaraanId = '';
        }),
        decoration: const InputDecoration(labelText: 'Merk'),
        validator: (val) => val == null ? 'Wajib diisi' : null,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Gagal memuat Merk'),
    );
  }

  Widget _buildTypeChassisDropdown() {
    final options = ref.watch(
      typeChassisOptionsFamilyProvider(_selectedMerkId),
    );
    return options.when(
      data: (items) => DropdownButtonFormField<String>(
        value: items.any((item) => item.id == _selectedTypeChassisId)
            ? _selectedTypeChassisId
            : null,
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item.id,
                child: Text(item.name),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() {
          _selectedTypeChassisId = value!;
          _selectedJenisKendaraanId = '';
        }),
        decoration: const InputDecoration(labelText: 'Type Chassis'),
        validator: (val) => val == null ? 'Wajib diisi' : null,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Gagal memuat Type Chassis'),
    );
  }

  Widget _buildJenisKendaraanDropdown() {
    final options = ref.watch(
      jenisKendaraanOptionsFamilyProvider(_selectedTypeChassisId),
    );
    return options.when(
      data: (items) => DropdownButtonFormField<String>(
        value: items.any((item) => item.id == _selectedJenisKendaraanId)
            ? _selectedJenisKendaraanId
            : null,
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item.id,
                child: Text(item.name),
              ),
            )
            .toList(),
        onChanged: (value) =>
            setState(() => _selectedJenisKendaraanId = value!),
        decoration: const InputDecoration(labelText: 'Jenis Kendaraan'),
        validator: (val) => val == null ? 'Wajib diisi' : null,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Gagal memuat Jenis Kendaraan'),
    );
  }

  Widget _buildJenisPengajuanDropdown() {
    final options = ref.watch(jenisPengajuanOptionsProvider);
    return options.when(
      data: (items) => DropdownButtonFormField<int>(
        value: _selectedJenisPengajuanId,
        items: items
            .map(
              (item) =>
                  DropdownMenuItem<int>(value: item.id, child: Text(item.name)),
            )
            .toList(),
        onChanged: (value) =>
            setState(() => _selectedJenisPengajuanId = value!),
        decoration: const InputDecoration(labelText: 'Jenis Pengajuan'),
        validator: (val) => val == null ? 'Wajib diisi' : null,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Gagal memuat Jenis Pengajuan'),
    );
  }

  void _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref
            .read(transaksiRepositoryProvider)
            .updateTransaksi(
              transaksiId: widget.transaksi.id,
              customerId: _selectedCustomerId,
              jenisKendaraanId: _selectedJenisKendaraanId,
              jenisPengajuanId: _selectedJenisPengajuanId,
            );

        if (mounted) Navigator.of(context).pop();
        ref.invalidate(transaksiHistoryProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil diupdate!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
