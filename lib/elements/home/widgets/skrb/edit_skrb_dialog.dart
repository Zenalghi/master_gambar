// File: lib/elements/home/widgets/skrb/edit_skrb_dialog.dart
// Dialog untuk mengedit data inti SKRB (Customer, Kendaraan, Jenis Pengajuan).
// Digunakan dari tabel Permohonan SKRB ketika icon edit ditekan.

import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/option_item.dart';
import 'package:master_gambar/data/models/skrb.dart';
import 'package:master_gambar/elements/home/providers/skrb_providers.dart';
import 'package:master_gambar/elements/home/providers/transaksi_providers.dart';
import 'package:master_gambar/elements/home/repository/skrb_repository.dart';

class EditSkrbDialog extends ConsumerStatefulWidget {
  final Skrb skrb;

  const EditSkrbDialog({super.key, required this.skrb});

  @override
  ConsumerState<EditSkrbDialog> createState() => _EditSkrbDialogState();
}

class _EditSkrbDialogState extends ConsumerState<EditSkrbDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  int? _selectedCustomerId;
  int? _selectedMasterDataId;
  int? _selectedJenisPengajuanId;

  @override
  void initState() {
    super.initState();
    // Pre-populate dari data SKRB saat ini
    _selectedCustomerId = widget.skrb.customerId;
    _selectedMasterDataId = widget.skrb.masterDataId;
    _selectedJenisPengajuanId = widget.skrb.jenisPengajuanId;
  }

  Future<void> _handleSimpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(skrbRepositoryProvider);
      await repo.updateSkrbData(
        widget.skrb.id,
        customerId: _selectedCustomerId,
        masterDataId: _selectedMasterDataId,
        jenisPengajuanId: _selectedJenisPengajuanId,
      );
      // Invalidate providers agar list & detail reload
      ref.invalidate(skrbListProvider);
      ref.invalidate(skrbDetailProvider(widget.skrb.id));
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data SKRB berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] ?? e.message ?? 'Terjadi kesalahan.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $msg'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: Row(
        children: [
          Icon(
            Icons.edit_document,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Edit Data SKRB',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
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
              // Info SKRB
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.tag,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ID SKRB: ${widget.skrb.idSkrb}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (widget.skrb.transaksiId.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.receipt_long,
                        size: 13,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ID DWG: ${widget.skrb.transaksiId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 1. CUSTOMER
              DropdownSearch<OptionItem>(
                items: (String filter, _) =>
                    ref.read(customerOptionsSearchProvider(filter).future),
                itemAsString: (OptionItem item) => item.name,
                compareFn: (i1, i2) => i1.id == i2.id,
                selectedItem: _selectedCustomerId != null
                    ? OptionItem(
                        id: _selectedCustomerId!,
                        name: widget.skrb.customerName,
                      )
                    : null,
                onChanged: (OptionItem? item) {
                  setState(() => _selectedCustomerId = item?.id as int?);
                },
                decoratorProps: const DropDownDecoratorProps(
                  baseStyle: TextStyle(fontSize: 13, height: 1.0),
                  decoration: InputDecoration(
                    constraints: BoxConstraints(maxHeight: 42),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 10,
                    ),
                    labelStyle: TextStyle(fontSize: 12),
                    labelText: 'Customer',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: const TextFieldProps(
                    autofocus: true,
                    style: TextStyle(fontSize: 13, height: 1.0),
                    decoration: InputDecoration(
                      constraints: BoxConstraints(maxHeight: 42),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 10,
                      ),
                      hintStyle: TextStyle(fontSize: 13, height: 1.0),
                      hintText: 'Cari Customer...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  menuProps: const MenuProps(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  itemBuilder: (context, item, isSelected, isDisabled) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      height: 30,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.0,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
                validator: (item) => item == null && _selectedCustomerId == null
                    ? 'Wajib dipilih'
                    : null,
              ),

              const SizedBox(height: 14),

              // 2. MASTER DATA KENDARAAN
              DropdownSearch<OptionItem>(
                items: (String filter, _) =>
                    ref.read(transaksiMasterDataOptionsProvider(filter).future),
                itemAsString: (OptionItem item) => item.name,
                compareFn: (i1, i2) => i1.id == i2.id,
                selectedItem: _selectedMasterDataId != null
                    ? OptionItem(
                        id: _selectedMasterDataId!,
                        name:
                            '${widget.skrb.typeEngine} / ${widget.skrb.merk} / ${widget.skrb.chassisDisplayName} / ${widget.skrb.jenisKendaraan}',
                      )
                    : null,
                onChanged: (OptionItem? item) {
                  setState(() => _selectedMasterDataId = item?.id as int?);
                },
                decoratorProps: const DropDownDecoratorProps(
                  baseStyle: TextStyle(fontSize: 13, height: 1.0),
                  decoration: InputDecoration(
                    constraints: BoxConstraints(maxHeight: 42),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 10,
                    ),
                    labelStyle: TextStyle(fontSize: 12),
                    labelText:
                        'Pilih Kendaraan (Engine / Merk / Chassis / Jenis)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: const TextFieldProps(
                    autofocus: true,
                    style: TextStyle(fontSize: 13, height: 1.0),
                    decoration: InputDecoration(
                      constraints: BoxConstraints(maxHeight: 42),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 10,
                      ),
                      hintStyle: TextStyle(fontSize: 13, height: 1.0),
                      hintText: 'Cari kendaraan...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  menuProps: const MenuProps(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  itemBuilder: (context, item, isSelected, isDisabled) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      height: 30,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.0,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
                validator: (item) =>
                    item == null && _selectedMasterDataId == null
                    ? 'Wajib dipilih'
                    : null,
              ),

              const SizedBox(height: 14),

              // 3. JENIS PENGAJUAN
              _buildPengajuanDropdown(),

              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          onPressed: _loading ? null : _handleSimpan,
          icon: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save_outlined, size: 18),
          label: const Text('Simpan Perubahan'),
        ),
      ],
    );
  }

  Widget _buildPengajuanDropdown() {
    final optionsAsync = ref.watch(jenisPengajuanOptionsProvider);
    return optionsAsync.when(
      data: (items) {
        final selectedItem = items
            .where((e) => e.id == _selectedJenisPengajuanId)
            .firstOrNull;
        return DropdownSearch<OptionItem>(
          items: (filter, _) => items,
          itemAsString: (OptionItem item) => item.name,
          compareFn: (i1, i2) => i1.id == i2.id,
          selectedItem: selectedItem,
          onChanged: (OptionItem? item) {
            setState(() => _selectedJenisPengajuanId = item?.id as int?);
          },
          decoratorProps: DropDownDecoratorProps(
            baseStyle: const TextStyle(fontSize: 13, height: 1.0),
            decoration: InputDecoration(
              labelText: 'Jenis Pengajuan',
              labelStyle: const TextStyle(fontSize: 12),
              border: const OutlineInputBorder(),
              constraints: const BoxConstraints(maxHeight: 42),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 0,
              ),
              isDense: true,
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: false,
            fit: FlexFit.loose,
            constraints: const BoxConstraints(maxHeight: 250),
            menuProps: const MenuProps(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            itemBuilder: (context, item, isSelected, isDisabled) {
              return Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.centerLeft,
                color: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : null,
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
          validator: (item) => item == null ? 'Wajib diisi' : null,
        );
      },
      loading: () => const SizedBox(
        height: 32,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (err, stack) => const SizedBox(
        height: 32,
        child: Center(
          child: Text(
            'Error memuat jenis pengajuan',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
