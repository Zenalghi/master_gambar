// File: lib/elements/home/widgets/tambah_transaksi_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:dio/dio.dart';
import 'package:master_gambar/data/models/option_item.dart';
import 'package:master_gambar/elements/home/providers/transaksi_providers.dart';
import 'package:master_gambar/elements/home/repository/options_repository.dart';
import '../../../app/core/notifiers/refresh_notifier.dart';

class TambahTransaksiDialog extends ConsumerStatefulWidget {
  final VoidCallback onTransaksiAdded;

  const TambahTransaksiDialog({super.key, required this.onTransaksiAdded});

  @override
  ConsumerState<TambahTransaksiDialog> createState() =>
      _TambahTransaksiDialogState();
}

class _TambahTransaksiDialogState extends ConsumerState<TambahTransaksiDialog> {
  final _formKey = GlobalKey<FormState>();

  // Kita hanya butuh 3 state sekarang
  int? _selectedCustomerId;
  int? _selectedMasterDataId;
  int? _selectedJenisPengajuanId;

  void _resetAndRefresh() {
    setState(() {
      _selectedCustomerId = null;
      _selectedMasterDataId = null;
      _selectedJenisPengajuanId = null;
    });
    ref.read(refreshNotifierProvider.notifier).refresh();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Panggil repository dengan parameter baru
        await ref
            .read(optionsRepositoryProvider)
            .addTransaksi(
              customerId: _selectedCustomerId!,
              masterDataId: _selectedMasterDataId!,
              jenisPengajuanId: _selectedJenisPengajuanId!,
            );

        widget.onTransaksiAdded();

        if (mounted) Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
      } on DioException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menambah transaksi: ${e.response?.data['message'] ?? e.message}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Tambah Transaksi Baru'),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Form',
            onPressed: _resetAndRefresh,
          ),
        ],
      ),
      content: SizedBox(
        width: 700,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. CUSTOMER
              // 1. CUSTOMER (SEARCHABLE)
              DropdownSearch<OptionItem>(
                // Panggil provider family dengan teks filter
                items: (String filter, _) =>
                    ref.read(customerOptionsSearchProvider(filter).future),
                itemAsString: (OptionItem item) => item.name,
                compareFn: (i1, i2) => i1.id == i2.id,
                onChanged: (OptionItem? item) {
                  setState(() => _selectedCustomerId = item?.id as int?);
                },
                selectedItem: null,
                decoratorProps: const DropDownDecoratorProps(
                  decoration: InputDecoration(
                    labelText: 'Customer',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: "Cari Customer...",
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  menuProps: MenuProps(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                validator: (item) => item == null && _selectedCustomerId == null
                    ? 'Wajib dipilih'
                    : null,
              ),

              const SizedBox(height: 16),

              // 2. MASTER DATA KENDARAAN (Searchable Dropdown)
              DropdownSearch<OptionItem>(
                items: (String filter, _) =>
                    ref.read(transaksiMasterDataOptionsProvider(filter).future),
                itemAsString: (OptionItem item) => item.name,
                // --- PERBAIKAN: Tambahkan compareFn ---
                compareFn: (i1, i2) => i1.id == i2.id,
                // ------------------------------------
                onChanged: (OptionItem? item) {
                  setState(() => _selectedMasterDataId = item?.id as int?);
                },
                decoratorProps: const DropDownDecoratorProps(
                  decoration: InputDecoration(
                    labelText:
                        'Pilih Kendaraan (Engine / Merk / Chassis / Jenis)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: "Cari kendaraan...",
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  menuProps: MenuProps(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                validator: (item) =>
                    item == null && _selectedMasterDataId == null
                    ? 'Wajib dipilih'
                    : null,
              ),

              const SizedBox(height: 16),

              // 3. JENIS PENGAJUAN
              _buildStandardDropdown(
                label: 'Jenis Pengajuan',
                optionsProvider: jenisPengajuanOptionsProvider,
                selectedValue: _selectedJenisPengajuanId,
                onChanged: (val) =>
                    setState(() => _selectedJenisPengajuanId = val),
              ),
            ],
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
          child: const Text('Simpan Transaksi'),
        ),
      ],
    );
  }

  // Helper untuk dropdown biasa (Customer & Pengajuan)
  Widget _buildStandardDropdown({
    required String label,
    required FutureProvider<List<OptionItem>> optionsProvider,
    required int? selectedValue,
    required Function(int?) onChanged,
  }) {
    final options = ref.watch(optionsProvider);
    return options.when(
      data: (items) => DropdownButtonFormField<int>(
        value: selectedValue,
        items: items
            .map(
              (item) => DropdownMenuItem<int>(
                value: item.id as int,
                child: Text(item.name),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (val) => val == null ? 'Wajib diisi' : null,
      ),
      loading: () => const SizedBox(
        height: 50,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Text('Gagal memuat $label'),
    );
  }
}
