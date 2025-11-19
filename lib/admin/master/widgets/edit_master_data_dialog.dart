// File: lib/admin/master/widgets/edit_master_data_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:master_gambar/admin/master/models/master_data.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:master_gambar/data/models/option_item.dart';

class EditMasterDataDialog extends ConsumerStatefulWidget {
  final MasterData masterData;

  const EditMasterDataDialog({super.key, required this.masterData});

  @override
  ConsumerState<EditMasterDataDialog> createState() =>
      _EditMasterDataDialogState();
}

class _EditMasterDataDialogState extends ConsumerState<EditMasterDataDialog> {
  final _formKey = GlobalKey<FormState>();

  late int _selectedTypeEngineId;
  late int _selectedMerkId;
  late int _selectedTypeChassisId;
  late int _selectedJenisKendaraanId;

  // Untuk pre-fill dropdown, kita butuh object OptionItem
  late OptionItem _initialEngine;
  late OptionItem _initialMerk;
  late OptionItem _initialChassis;
  late OptionItem _initialJenis;

  @override
  void initState() {
    super.initState();
    // Inisialisasi ID
    _selectedTypeEngineId = widget.masterData.typeEngine.id;
    _selectedMerkId = widget.masterData.merk.id;
    _selectedTypeChassisId = widget.masterData.typeChassis.id;
    _selectedJenisKendaraanId = widget.masterData.jenisKendaraan.id;

    // Inisialisasi Object untuk Dropdown (Tampilan Awal)
    _initialEngine = OptionItem(
      id: widget.masterData.typeEngine.id,
      name: widget.masterData.typeEngine.name,
    );
    _initialMerk = OptionItem(
      id: widget.masterData.merk.id,
      name: widget.masterData.merk.name,
    );
    _initialChassis = OptionItem(
      id: widget.masterData.typeChassis.id,
      name: widget.masterData.typeChassis.name,
    );
    _initialJenis = OptionItem(
      id: widget.masterData.jenisKendaraan.id,
      name: widget.masterData.jenisKendaraan.name,
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(masterDataRepositoryProvider)
          .updateMasterData(
            id: widget.masterData.id,
            typeEngineId: _selectedTypeEngineId.toString(),
            merkId: _selectedMerkId.toString(),
            typeChassisId: _selectedTypeChassisId.toString(),
            jenisKendaraanId: _selectedJenisKendaraanId.toString(),
          );

      // Refresh tabel di parent
      ref
          .read(masterDataFilterProvider.notifier)
          .update((state) => Map.from(state));

      if (mounted) {
        Navigator.of(context).pop(); // Tutup dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Master Data berhasil diupdate!'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Master Data #${widget.masterData.id}'),
      content: SizedBox(
        width: 500, // Lebar dialog
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSearchableDropdown(
                  label: 'Type Engine',
                  provider: mdTypeEngineOptionsProvider,
                  initialItem: _initialEngine,
                  onChanged: (val) => _selectedTypeEngineId = val!.id,
                ),
                const SizedBox(height: 16),
                _buildSearchableDropdown(
                  label: 'Merk',
                  provider: mdMerkOptionsProvider,
                  initialItem: _initialMerk,
                  onChanged: (val) => _selectedMerkId = val!.id,
                ),
                const SizedBox(height: 16),
                _buildSearchableDropdown(
                  label: 'Type Chassis',
                  provider: mdTypeChassisOptionsProvider,
                  initialItem: _initialChassis,
                  onChanged: (val) => _selectedTypeChassisId = val!.id,
                ),
                const SizedBox(height: 16),
                _buildSearchableDropdown(
                  label: 'Jenis Kendaraan',
                  provider: mdJenisKendaraanOptionsProvider,
                  initialItem: _initialJenis,
                  onChanged: (val) => _selectedJenisKendaraanId = val!.id,
                ),
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
          onPressed: _submit,
          child: const Text('Simpan Perubahan'),
        ),
      ],
    );
  }

  Widget _buildSearchableDropdown({
    required String label,
    required FutureProviderFamily<List<OptionItem>, String> provider,
    required OptionItem initialItem,
    required Function(OptionItem?) onChanged,
  }) {
    return DropdownSearch<OptionItem>(
      // V6 Syntax
      items: (String filter, _) => ref.read(provider(filter).future),
      itemAsString: (OptionItem item) => item.name,
      compareFn: (item1, item2) => item1.id == item2.id,
      selectedItem: initialItem, // Set nilai awal untuk edit
      onChanged: onChanged,
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
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
      validator: (item) => item == null ? 'Wajib dipilih' : null,
    );
  }
}
