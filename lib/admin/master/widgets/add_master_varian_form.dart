import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:dio/dio.dart';
import '../../../../data/models/option_item.dart';
import '../providers/master_data_providers.dart';
import '../repository/master_data_repository.dart';

class AddMasterVarianForm extends ConsumerStatefulWidget {
  const AddMasterVarianForm({super.key});

  @override
  ConsumerState<AddMasterVarianForm> createState() =>
      _AddMasterVarianFormState();
}

class _AddMasterVarianFormState extends ConsumerState<AddMasterVarianForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaVarianController = TextEditingController();
  int? _selectedJenisKendaraanId;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaVarianController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(masterDataRepositoryProvider)
          .addMasterVarian(
            jenisKendaraanId: _selectedJenisKendaraanId!,
            namaVarian: _namaVarianController.text,
          );

      _namaVarianController.clear();

      // Refresh tabel Master Varian
      ref
          .read(masterVarianFilterProvider.notifier)
          .update((state) => Map.from(state));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Master Varian berhasil ditambahkan!'),
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              // --- 1. Dropdown Jenis Kendaraan ---
              Expanded(
                flex: 3,
                child: DropdownSearch<OptionItem>(
                  items: (String filter, _) =>
                      ref.read(mdJenisKendaraanOptionsProvider(filter).future),
                  itemAsString: (OptionItem item) => item.name,
                  compareFn: (item1, item2) => item1.id == item2.id,
                  onChanged: (OptionItem? item) {
                    _selectedJenisKendaraanId = item?.id as int?;
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
                      labelText: 'Pilih Jenis Kendaraan',
                      hintText: 'Ketik untuk mencari...',
                      isDense: true,
                      border: OutlineInputBorder(),
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
                        hintText: "Cari Jenis Kendaraan...",
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
              ),

              const SizedBox(width: 16),

              // --- 2. Input Text Nama Varian ---
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _namaVarianController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    labelStyle: TextStyle(fontSize: 14),
                    labelText: 'Nama Master Varian Baru',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Wajib diisi' : null,
                ),
              ),

              const SizedBox(width: 16),

              // --- 3. Tombol Tambah ---
              ElevatedButton.icon(
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.add),
                label: const Text('Tambah'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                ),
                onPressed: _isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
