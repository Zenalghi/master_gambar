// File: lib/admin/master/widgets/add_varian_body_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:dio/dio.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:master_gambar/data/models/option_item.dart';

class AddVarianBodyForm extends ConsumerStatefulWidget {
  const AddVarianBodyForm({super.key});

  @override
  ConsumerState<AddVarianBodyForm> createState() => _AddVarianBodyFormState();
}

class _AddVarianBodyFormState extends ConsumerState<AddVarianBodyForm> {
  final _formKey = GlobalKey<FormState>();
  final _varianController = TextEditingController();

  int? _selectedMasterDataId;

  @override
  void dispose() {
    _varianController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final selectedMasterData = ref.watch(selectedMasterDataFilterProvider);
    try {
      await ref
          .read(masterDataRepositoryProvider)
          .addVarianBody(
            masterDataId: selectedMasterData!.id,
            varianBody: _varianController.text,
          );

      // Reset form
      // _varianController.clear();
      // setState(() {
      //   _selectedMasterDataId = null;
      // });

      // Refresh tabel varian body
      ref
          .read(varianBodyFilterProvider.notifier)
          .update((state) => Map.from(state));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Varian Body berhasil ditambahkan!'),
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
    final selectedMasterData = ref.watch(selectedMasterDataFilterProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Dropdown Pencarian Master Data
              Expanded(
                flex: 3,
                child: DropdownSearch<OptionItem>(
                  items: (String filter, _) =>
                      ref.read(masterDataOptionsProvider(filter).future),
                  itemAsString: (OptionItem item) => item.name,
                  compareFn: (item1, item2) => item1.id == item2.id,
                  selectedItem: selectedMasterData,
                  onChanged: (OptionItem? item) {
                    // SIMPAN OBJECT LENGKAP KE PROVIDER
                    ref.read(selectedMasterDataFilterProvider.notifier).state =
                        item;
                  },
                  decoratorProps: const DropDownDecoratorProps(
                    baseStyle: TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      constraints: BoxConstraints(maxHeight: 32),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 10,
                      ),
                      labelStyle: TextStyle(fontSize: 12),
                      labelText:
                          'Pilih Master Data (Engine / Merk / Chassis / Jenis)',
                      hintText: 'Ketik untuk mencari...',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: const TextFieldProps(
                      style: TextStyle(fontSize: 13, height: 1.0),
                      decoration: InputDecoration(
                        constraints: BoxConstraints(maxHeight: 32),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 10,
                        ),
                        hintStyle: TextStyle(fontSize: 13, height: 1.0),
                        hintText: "Cari (contoh: Hino, Box, dll)...",
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    menuProps: const MenuProps(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    itemBuilder: (context, item, isSelected, isDisabled) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        height:
                            30, // Paksa tinggi item menjadi 30px (atau lebih kecil sesuai selera)
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
                                : Colors.black87,
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
              ),

              const SizedBox(width: 16),

              // 2. Input Nama Varian Body
              Expanded(
                flex: 2,
                child: TextFormField(
                  style: const TextStyle(fontSize: 14),
                  controller: _varianController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelStyle: TextStyle(fontSize: 14),
                    labelText: 'Nama Varian Body Baru',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Wajib diisi' : null,
                ),
              ),

              const SizedBox(width: 16),

              // 3. Tombol Tambah
              Padding(
                padding: const EdgeInsets.only(top: 0),
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
}
