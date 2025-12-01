import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:master_gambar/admin/master/models/master_data.dart';
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

  // Gunakan OptionItem lengkap agar dropdown terisi nama
  OptionItem? _selectedTypeEngine;
  OptionItem? _selectedMerk;
  OptionItem? _selectedTypeChassis;
  OptionItem? _selectedJenisKendaraan;

  @override
  Widget build(BuildContext context) {
    // --- LISTENER UNTUK COPY DATA ---
    ref.listen<MasterData?>(masterDataToCopyProvider, (prev, next) {
      if (next != null) {
        setState(() {
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
            content: Text('Data disalin! Silakan ubah field yang diperlukan.'),
            backgroundColor: Colors.blue,
          ),
        );
        // Reset provider agar tidak trigger ulang
        ref.read(masterDataToCopyProvider.notifier).state = null;
      }
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
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
                padding: const EdgeInsets.only(),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
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

  // ... (method _submit dan _buildSearchableDropdown sama seperti sebelumnya,
  // pastikan mengirim ID sebagai int: typeEngineId: _selectedTypeEngine!.id as int)
  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(masterDataRepositoryProvider)
          .addMasterData(
            typeEngineId: _selectedTypeEngine!.id as int,
            merkId: _selectedMerk!.id as int,
            typeChassisId: _selectedTypeChassis!.id as int,
            jenisKendaraanId: _selectedJenisKendaraan!.id as int,
          );

      // Reset form visual
      // setState(() {
      //   _selectedTypeEngine = null;
      //   _selectedMerk = null;
      //   _selectedTypeChassis = null;
      //   _selectedJenisKendaraan = null;
      // });

      // Refresh tabel
      ref
          .read(masterDataFilterProvider.notifier)
          .update((state) => Map.from(state));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil ditambahkan!'),
            backgroundColor: Colors.green,
            //durasi 1 detik
            duration: Duration(seconds: 1),
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.response?.data['message'] ?? e.message}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Widget _buildSearchableDropdown({
    required String label,
    required FutureProviderFamily<List<OptionItem>, String> provider,
    required OptionItem? selectedItem,
    required Function(OptionItem?) onChanged,
  }) {
    return Expanded(
      child: DropdownSearch<OptionItem>(
        items: (String filter, _) => ref.read(provider(filter).future),
        itemAsString: (OptionItem item) => item.name,
        compareFn: (item1, item2) => item1.id == item2.id,
        selectedItem: selectedItem, // <-- Gunakan state lokal
        onChanged: onChanged,
        decoratorProps: DropDownDecoratorProps(
          baseStyle: const TextStyle(fontSize: 13, height: 1.0),
          decoration: InputDecoration(
            constraints: const BoxConstraints(maxHeight: 32),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 10,
            ),
            labelStyle: const TextStyle(fontSize: 12),
            labelText: label,
            isDense: true,
            border: const OutlineInputBorder(),
          ),
        ),

        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: const TextFieldProps(
            style: TextStyle(fontSize: 13, height: 1.0),
            decoration: InputDecoration(
              constraints: BoxConstraints(maxHeight: 32),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              hintStyle: TextStyle(fontSize: 13, height: 1.0),
              hintText: "Cari...",
              prefixIcon: Icon(Icons.search),
            ),
          ),
          itemBuilder: (context, item, isSelected, isDisabled) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              height:
                  30, // Paksa tinggi item menjadi 30px (atau lebih kecil sesuai selera)
              alignment: Alignment.centerLeft,
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.0,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
        validator: (item) => item == null ? 'Wajib dipilih' : null,
      ),
    );
  }
}
