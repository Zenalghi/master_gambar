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

  // Kita hanya butuh 1 ID ini untuk menghubungkan Varian Body ke Master Data
  int? _selectedMasterDataId;

  @override
  void dispose() {
    _varianController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(masterDataRepositoryProvider)
          .addVarianBody(
            masterDataId: _selectedMasterDataId!,
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
                  // Fungsi ini akan dipanggil saat user mengetik
                  items: (String filter, _) =>
                      ref.read(masterDataOptionsProvider(filter).future),
                  itemAsString: (OptionItem item) => item.name,
                  // --- PERBAIKAN UTAMA DI SINI: Tambahkan compareFn ---
                  compareFn: (item1, item2) => item1.id == item2.id,
                  // --------------------------------------------------
                  onChanged: (OptionItem? item) {
                    setState(() {
                      _selectedMasterDataId = item?.id as int?;
                    });
                  },
                  selectedItem:
                      null, // Kita biarkan null agar kosong setelah reset
                  decoratorProps: const DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText:
                          'Pilih Master Data (Engine / Merk / Chassis / Jenis)',
                      hintText: 'Ketik untuk mencari...',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  popupProps: const PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        hintText: "Cari (contoh: Hino, Box, dll)...",
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
              ),

              const SizedBox(width: 16),

              // 2. Input Nama Varian Body
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _varianController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
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
                padding: const EdgeInsets.only(top: 4.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 17,
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
