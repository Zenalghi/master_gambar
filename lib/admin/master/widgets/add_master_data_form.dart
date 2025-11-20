// File: lib/admin/master/widgets/add_master_data_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:master_gambar/admin/master/models/master_data.dart'; // Import Model
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

  // Kita simpan OptionItem lengkap agar nama bisa tampil di dropdown saat di-copy
  OptionItem? _selectedTypeEngine;
  OptionItem? _selectedMerk;
  OptionItem? _selectedTypeChassis;
  OptionItem? _selectedJenisKendaraan;

  @override
  Widget build(BuildContext context) {
    // 1. DENGARKAN PERUBAHAN DARI TOMBOL COPY
    ref.listen<MasterData?>(masterDataToCopyProvider, (previous, next) {
      if (next != null) {
        setState(() {
          // Isi form dengan data yang dicopy
          _selectedTypeEngine = OptionItem(
            id: next.typeEngine.id,
            name: next.typeEngine.name,
          );
          _selectedMerk = OptionItem(id: next.merk.id, name: next.merk.name);
          _selectedTypeChassis = OptionItem(
            id: next.typeChassis.id,
            name: next.typeChassis.name,
          );
          _selectedJenisKendaraan = OptionItem(
            id: next.jenisKendaraan.id,
            name: next.jenisKendaraan.name,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Data disalin ke form. Silakan ubah salah satu field.',
            ),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 1),
          ),
        );

        // Reset provider agar bisa dicopy ulang jika perlu
        ref.read(masterDataToCopyProvider.notifier).state = null;
      }
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchableDropdown(
                label: 'Type Engine',
                provider: mdTypeEngineOptionsProvider,
                selectedItem: _selectedTypeEngine,
                onChanged: (val) => _selectedTypeEngine = val,
              ),
              const SizedBox(width: 16),
              _buildSearchableDropdown(
                label: 'Merk',
                provider: mdMerkOptionsProvider,
                selectedItem: _selectedMerk,
                onChanged: (val) => _selectedMerk = val,
              ),
              const SizedBox(width: 16),
              _buildSearchableDropdown(
                label: 'Type Chassis',
                provider: mdTypeChassisOptionsProvider,
                selectedItem: _selectedTypeChassis,
                onChanged: (val) => _selectedTypeChassis = val,
              ),
              const SizedBox(width: 16),
              _buildSearchableDropdown(
                label: 'Jenis Kendaraan',
                provider: mdJenisKendaraanOptionsProvider,
                selectedItem: _selectedJenisKendaraan,
                onChanged: (val) => _selectedJenisKendaraan = val,
              ),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
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

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(masterDataRepositoryProvider)
          .addMasterData(
            typeEngineId: _selectedTypeEngine!.id.toString(),
            merkId: _selectedMerk!.id.toString(),
            typeChassisId: _selectedTypeChassis!.id.toString(),
            jenisKendaraanId: _selectedJenisKendaraan!.id.toString(),
          );

      // Reset form
      setState(() {
        _selectedTypeEngine = null;
        _selectedMerk = null;
        _selectedTypeChassis = null;
        _selectedJenisKendaraan = null;
      });

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

  Widget _buildSearchableDropdown({
    required String label,
    required FutureProviderFamily<List<OptionItem>, String> provider,
    required Function(OptionItem?) onChanged,
    required OptionItem? selectedItem,
  }) {
    return Expanded(
      child: DropdownSearch<OptionItem>(
        items: (String filter, _) => ref.read(provider(filter).future),
        itemAsString: (OptionItem item) => item.name,
        compareFn: (item1, item2) => item1.id == item2.id,
        selectedItem: selectedItem, // Gunakan object lengkap
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
      ),
    );
  }
}
