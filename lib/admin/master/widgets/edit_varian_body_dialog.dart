// File: lib/admin/master/widgets/edit_varian_body_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:dio/dio.dart';
import 'package:master_gambar/admin/master/models/varian_body.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:master_gambar/data/models/option_item.dart';

class EditVarianBodyDialog extends ConsumerStatefulWidget {
  final VarianBody varianBody;

  const EditVarianBodyDialog({super.key, required this.varianBody});

  @override
  ConsumerState<EditVarianBodyDialog> createState() =>
      _EditVarianBodyDialogState();
}

class _EditVarianBodyDialogState extends ConsumerState<EditVarianBodyDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _varianController;

  int? _selectedMasterDataId;
  late OptionItem _initialMasterData;

  @override
  void initState() {
    super.initState();
    _varianController = TextEditingController(text: widget.varianBody.name);
    _selectedMasterDataId = widget.varianBody.masterData.id;

    // Siapkan object untuk initial value dropdown
    // Kita format namanya agar terlihat jelas di dropdown (seperti format pencarian)
    final md = widget.varianBody.masterData;
    final name =
        '${md.typeEngine.name} / ${md.merk.name} / ${md.typeChassis.name} / ${md.jenisKendaraan.name}';
    _initialMasterData = OptionItem(id: md.id, name: name);
  }

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
          .updateVarianBody(
            id: widget.varianBody.id,
            masterDataId: _selectedMasterDataId!,
            varianBody: _varianController.text,
          );

      // Refresh tabel di parent
      ref
          .read(varianBodyFilterProvider.notifier)
          .update((state) => Map.from(state));

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Varian Body berhasil diupdate!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      // Error dari Server / Jaringan
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Server Error: ${e.response?.data['message'] ?? e.message}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // --- PENANGKAPAN ERROR LAINNYA (Misal: Parsing JSON) ---
      // Ini akan memberi tahu Anda jika Flutter gagal membaca respons dari server
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('App Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Varian Body #${widget.varianBody.id}'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Dropdown Master Data
                DropdownSearch<OptionItem>(
                  items: (String filter, _) =>
                      ref.read(masterDataOptionsProvider(filter).future),
                  itemAsString: (OptionItem item) => item.name,
                  compareFn: (item1, item2) => item1.id == item2.id,
                  selectedItem: _initialMasterData,
                  onChanged: (OptionItem? item) {
                    setState(() {
                      _selectedMasterDataId = item?.id as int?;
                    });
                  },
                  decoratorProps: const DropDownDecoratorProps(
                    baseStyle: TextStyle(fontSize: 13, height: 1.0),
                    decoration: InputDecoration(
                      constraints: BoxConstraints(maxHeight: 32),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 10,
                      ),
                      labelStyle: TextStyle(fontSize: 12),
                      labelText: 'Master Data Induk',
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
                        constraints: BoxConstraints(maxHeight: 32),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 10,
                        ),
                        hintStyle: TextStyle(fontSize: 13, height: 1.0),
                        hintText: "Cari Master Data...",
                        prefixIcon: Icon(Icons.search),
                      ),
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
                  validator: (item) => item == null ? 'Wajib dipilih' : null,
                ),

                const SizedBox(height: 16),

                // 2. Input Nama Varian
                TextFormField(
                  controller: _varianController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Nama Varian Body',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Wajib diisi' : null,
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
}
