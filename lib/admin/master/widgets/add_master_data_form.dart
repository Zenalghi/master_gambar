// File: lib/admin/master/widgets/add_master_data_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:master_gambar/data/models/option_item.dart';

class AddMasterDataForm extends ConsumerStatefulWidget {
  const AddMasterDataForm({super.key});

  @override
  ConsumerState<AddMasterDataForm> createState() => _AddMasterDataFormState();
}

class _AddMasterDataFormState extends ConsumerState<AddMasterDataForm> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedTypeEngineId;
  int? _selectedMerkId;
  int? _selectedTypeChassisId;
  int? _selectedJenisKendaraanId;

  // Controller untuk reset dropdown (opsional di v6, tapi bagus untuk UX)
  final _engineKey = GlobalKey<DropdownSearchState<OptionItem>>();
  final _merkKey = GlobalKey<DropdownSearchState<OptionItem>>();
  final _chassisKey = GlobalKey<DropdownSearchState<OptionItem>>();
  final _jenisKey = GlobalKey<DropdownSearchState<OptionItem>>();

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(masterDataRepositoryProvider)
          .addMasterData(
            typeEngineId: _selectedTypeEngineId.toString(),
            merkId: _selectedMerkId.toString(),
            typeChassisId: _selectedTypeChassisId.toString(),
            jenisKendaraanId: _selectedJenisKendaraanId.toString(),
          );

      // Reset form state
      setState(() {
        _selectedTypeEngineId = null;
        _selectedMerkId = null;
        _selectedTypeChassisId = null;
        _selectedJenisKendaraanId = null;
      });

      // Reset visual dropdown
      _engineKey.currentState?.clear();
      _merkKey.currentState?.clear();
      _chassisKey.currentState?.clear();
      _jenisKey.currentState?.clear();

      // Refresh tabel
      ref
          .read(masterDataFilterProvider.notifier)
          .update((state) => Map.from(state));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Master Data berhasil ditambahkan!'),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment
                .start, // Agar align dengan tombol jika error muncul
            children: [
              _buildSearchableDropdown(
                key: _engineKey,
                label: 'Type Engine',
                provider: mdTypeEngineOptionsProvider,
                onChanged: (val) => _selectedTypeEngineId = val?.id,
              ),
              const SizedBox(width: 16),
              _buildSearchableDropdown(
                key: _merkKey,
                label: 'Merk',
                provider: mdMerkOptionsProvider,
                onChanged: (val) => _selectedMerkId = val?.id,
              ),
              const SizedBox(width: 16),
              _buildSearchableDropdown(
                key: _chassisKey,
                label: 'Type Chassis',
                provider: mdTypeChassisOptionsProvider,
                onChanged: (val) => _selectedTypeChassisId = val?.id,
              ),
              const SizedBox(width: 16),
              _buildSearchableDropdown(
                key: _jenisKey,
                label: 'Jenis Kendaraan',
                provider: mdJenisKendaraanOptionsProvider,
                onChanged: (val) => _selectedJenisKendaraanId = val?.id,
              ),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                ), // Sedikit padding agar sejajar visual
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 24,
                    ),
                  ),
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchableDropdown({
    required GlobalKey<DropdownSearchState<OptionItem>> key,
    required String label,
    required FutureProviderFamily<List<OptionItem>, String> provider,
    required Function(OptionItem?) onChanged,
  }) {
    return Expanded(
      child: DropdownSearch<OptionItem>(
        key: key,
        // V6: Gunakan 'items' dengan fungsi untuk async
        items: (String filter, _) => ref.read(provider(filter).future),
        itemAsString: (OptionItem item) => item.name,
        compareFn: (item1, item2) =>
            item1.id == item2.id, // Penting untuk pre-selection/validasi
        onChanged: onChanged,
        // V6: decoratorProps menggantikan dropdownDecoratorProps
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
          menuProps: MenuProps(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        validator: (item) => item == null ? 'Wajib dipilih' : null,
      ),
    );
  }
}
