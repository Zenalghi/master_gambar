import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/elements/home/providers/transaksi_providers.dart';
import 'package:master_gambar/elements/home/repository/options_repository.dart';

class TambahTransaksiDialog extends ConsumerStatefulWidget {
  final VoidCallback onTransaksiAdded;

  const TambahTransaksiDialog({super.key, required this.onTransaksiAdded});

  @override
  ConsumerState<TambahTransaksiDialog> createState() =>
      _TambahTransaksiDialogState();
}

class _TambahTransaksiDialogState extends ConsumerState<TambahTransaksiDialog> {
  // State lokal untuk menyimpan ID yang dipilih
  int? _selectedCustomerId;
  String? _selectedTypeEngineId;
  String? _selectedMerkId;
  String? _selectedTypeChassisId;
  String? _selectedJenisKendaraanId;
  int? _selectedJenisPengajuanId;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Transaksi Baru'),
      content: SizedBox(
        width: 500, // Atur lebar dialog
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Tambah Transaksi'),
        ),
      ],
    );
  }

  // Kumpulan method untuk membangun setiap dropdown
  // Pola ini sama persis dengan dialog edit, memastikan konsistensi

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
        onChanged: (value) => setState(() => _selectedCustomerId = value),
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
          _selectedTypeEngineId = value;
          _selectedMerkId = null;
          _selectedTypeChassisId = null;
          _selectedJenisKendaraanId = null;
        }),
        decoration: const InputDecoration(labelText: 'Type Engine'),
        validator: (val) => val == null ? 'Wajib diisi' : null,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Gagal memuat Type Engine'),
    );
  }

  Widget _buildMerkDropdown() {
    final options = ref.watch(merkOptionsFamilyProvider(_selectedTypeEngineId));
    return options.when(
      data: (items) => DropdownButtonFormField<String>(
        value: _selectedMerkId,
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item.id,
                child: Text(item.name),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() {
          _selectedMerkId = value;
          _selectedTypeChassisId = null;
          _selectedJenisKendaraanId = null;
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
        value: _selectedTypeChassisId,
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item.id,
                child: Text(item.name),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() {
          _selectedTypeChassisId = value;
          _selectedJenisKendaraanId = null;
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
        value: _selectedJenisKendaraanId,
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item.id,
                child: Text(item.name),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _selectedJenisKendaraanId = value),
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
        onChanged: (value) => setState(() => _selectedJenisPengajuanId = value),
        decoration: const InputDecoration(labelText: 'Jenis Pengajuan'),
        validator: (val) => val == null ? 'Wajib diisi' : null,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Gagal memuat Jenis Pengajuan'),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref
            .read(transaksiRepositoryProvider)
            .addTransaksi(
              customerId: _selectedCustomerId!,
              typeEngineId: _selectedTypeEngineId!,
              merkId: _selectedMerkId!,
              typeChassisId: _selectedTypeChassisId!,
              jenisKendaraanId: _selectedJenisKendaraanId!,
              jenisPengajuanId: _selectedJenisPengajuanId!,
            );

        // Panggil callback untuk refresh tabel di parent
        widget.onTransaksiAdded();

        if (mounted) Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambah transaksi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
