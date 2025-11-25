// File: lib/elements/home/widgets/edit_transaksi_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:dio/dio.dart';
import 'package:master_gambar/data/models/transaksi.dart';
import 'package:master_gambar/data/models/option_item.dart';
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
  final _formKey = GlobalKey<FormState>();

  // State lokal
  late int _selectedCustomerId;
  late int _selectedMasterDataId;
  late int _selectedJenisPengajuanId;

  // Untuk tampilan awal dropdown Master Data
  late OptionItem _initialMasterDataOption;

  @override
  void initState() {
    super.initState();
    // 1. Isi ID
    _selectedCustomerId = widget.transaksi.customer.id;
    _selectedMasterDataId = widget.transaksi.masterDataId;
    _selectedJenisPengajuanId = widget.transaksi.fPengajuan.id;

    // 2. Buat object OptionItem untuk tampilan awal DropdownSearch
    // Gabungkan nama A/B/C/D yang sudah ada di transaksi
    final displayName =
        "${widget.transaksi.aTypeEngine.typeEngine} / "
        "${widget.transaksi.bMerk.merk} / "
        "${widget.transaksi.cTypeChassis.typeChassis} / "
        "${widget.transaksi.dJenisKendaraan.jenisKendaraan}";

    _initialMasterDataOption = OptionItem(
      id: _selectedMasterDataId,
      name: displayName,
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
              masterDataId: _selectedMasterDataId, // Kirim ID Master Data
              jenisPengajuanId: _selectedJenisPengajuanId,
            );

        if (mounted) Navigator.of(context).pop();

        // Gunakan dataSource provider untuk refresh yang benar
        // (Pastikan Anda mengimport file datasource jika perlu)
        // Atau invalidate history provider
        ref.invalidate(transaksiFilterProvider); // Cara refresh via filter
        // Atau jika menggunakan DataSource:
        // ref.read(transaksiDataSourceProvider).refreshDatasource();

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
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Ya, Hapus'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _submitDelete();
              },
            ),
          ],
        );
      },
    );
  }

  void _submitDelete() async {
    try {
      await ref
          .read(transaksiRepositoryProvider)
          .deleteTransaksi(transaksiId: widget.transaksi.id);
      if (mounted) Navigator.of(context).pop();
      ref.invalidate(transaksiFilterProvider); // Refresh tabel
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
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. CUSTOMER
                _buildStandardDropdown(
                  label: 'Customer',
                  optionsProvider: customerOptionsProvider,
                  selectedValue: _selectedCustomerId,
                  onChanged: (val) => setState(() => _selectedCustomerId = val),
                ),

                const SizedBox(height: 16),

                // 2. MASTER DATA (DropdownSearch)
                DropdownSearch<OptionItem>(
                  items: (String filter, _) => ref.read(
                    transaksiMasterDataOptionsProvider(filter).future,
                  ),
                  itemAsString: (OptionItem item) => item.name,
                  compareFn: (i1, i2) => i1.id == i2.id, // Penting!
                  selectedItem: _initialMasterDataOption, // Nilai awal
                  onChanged: (OptionItem? item) {
                    if (item != null) {
                      setState(() => _selectedMasterDataId = item.id as int);
                    }
                  },
                  decoratorProps: const DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: 'Kendaraan (Engine / Merk / Chassis / Jenis)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  popupProps: const PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        hintText: "Cari...",
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  validator: (item) =>
                      item == null && _selectedMasterDataId == 0
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
      ),
      actions: [
        Row(
          children: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: _showDeleteConfirmationDialog,
              child: const Text('Hapus'),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _submitUpdate,
              child: const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStandardDropdown({
    required String label,
    required FutureProvider<List<OptionItem>> optionsProvider,
    required int selectedValue,
    required Function(int) onChanged,
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
        onChanged: (val) {
          if (val != null) onChanged(val);
        },
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
