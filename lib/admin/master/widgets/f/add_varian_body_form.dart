//lib/admin/master/widgets/add_varian_body_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:dio/dio.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:master_gambar/data/models/option_item.dart';

class AddVarianBodyForm extends ConsumerStatefulWidget {
  const AddVarianBodyForm({super.key, required this.refreshToken});

  final int refreshToken;

  @override
  ConsumerState<AddVarianBodyForm> createState() => _AddVarianBodyFormState();
}

class _AddVarianBodyFormState extends ConsumerState<AddVarianBodyForm> {
  final _formKey = GlobalKey<FormState>();
  List<OptionItem> _selectedMasterVarians = []; // Untuk multi-select
  bool _isLoading = false;

  @override
  void didUpdateWidget(covariant AddVarianBodyForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      setState(() => _selectedMasterVarians = []);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final selectedMasterData = ref.read(selectedMasterDataFilterProvider);
    if (selectedMasterData == null || _selectedMasterVarians.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih Master Data dan minimal 1 Varian!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final List<String> varianBodies = _selectedMasterVarians
          .map((e) => e.name)
          .toList();

      final result = await ref
          .read(masterDataRepositoryProvider)
          .addVarianBody(
            masterDataId: selectedMasterData.id,
            varianBodies: varianBodies,
          );

      setState(() {
        _selectedMasterVarians = [];
      });

      ref
          .read(varianBodyFilterProvider.notifier)
          .update((state) => Map.from(state));

      if (!mounted) return;

      if (result.skipped.isNotEmpty) {
        final skippedText = result.skipped.join(', ');
        final createdText = result.created.isNotEmpty
            ? ' ${result.created.length} varian baru berhasil disimpan.'
            : '';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data sudah ada: $skippedText.$createdText'),
            backgroundColor: result.created.isNotEmpty
                ? const Color.fromARGB(255, 0, 51, 27)
                : const Color.fromARGB(255, 163, 122, 0),
          ),
        );
      } else {
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedMasterData = ref.watch(selectedMasterDataFilterProvider);

    final int? jkId = selectedMasterData != null
        ? int.tryParse(
            selectedMasterData.data?['d_jenis_kendaraan_id']?.toString() ?? '',
          )
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Dropdown Master Data
              Expanded(
                flex: 2,
                child: DropdownSearch<OptionItem>(
                  items: (String filter, _) =>
                      ref.read(masterDataOptionsProvider(filter).future),
                  itemAsString: (OptionItem item) => item.name,
                  compareFn: (item1, item2) => item1.id == item2.id,
                  selectedItem: selectedMasterData,
                  onChanged: (OptionItem? item) {
                    ref.read(selectedMasterDataFilterProvider.notifier).state =
                        item;
                    // Reset varian saat master data berubah
                    setState(() => _selectedMasterVarians = []);
                  },
                  decoratorProps: const DropDownDecoratorProps(
                    baseStyle: TextStyle(fontSize: 13),
                    decoration: InputDecoration(
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
                      autofocus: true,
                      style: TextStyle(fontSize: 13, height: 1.0),
                      decoration: InputDecoration(
                        constraints: BoxConstraints(maxHeight: 42),
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
                      item == null && selectedMasterData == null
                      ? 'Wajib dipilih'
                      : null,
                ),
              ),

              const SizedBox(width: 16),

              // 2. Dropdown Checkbox Master Varian (Enabled jika Master Data dipilih)
              Expanded(
                flex: 3,
                child: Builder(
                  builder: (context) {
                    final double chipSpacing = 8;
                    final double maxWidth =
                        MediaQuery.of(context).size.width * 0.38;
                    double currentRowWidth = 0;
                    int rowCount = 1;
                    for (final item in _selectedMasterVarians) {
                      final text = item.name;
                      final textWidth = (text.length * 8.5) + 32 + 24;
                      if (currentRowWidth + textWidth > maxWidth) {
                        rowCount++;
                        currentRowWidth = textWidth;
                      } else {
                        currentRowWidth += textWidth + chipSpacing;
                      }
                    }
                    final double maxHeight = rowCount * 32.0;
                    return DropdownSearch<OptionItem>.multiSelection(
                      enabled: selectedMasterData != null,
                      items: (String filter, _) async {
                        if (jkId == null) return [];
                        return await ref.read(
                          masterVarianOptionsFamilyProvider(jkId).future,
                        );
                      },
                      itemAsString: (OptionItem item) => item.name,
                      compareFn: (item1, item2) => item1.id == item2.id,
                      selectedItems: _selectedMasterVarians,
                      onChanged: (List<OptionItem> items) {
                        setState(() => _selectedMasterVarians = items);
                      },
                      selectedItemsScrollProps: ScrollProps(
                        physics: const BouncingScrollPhysics(),
                      ),
                      decoratorProps: DropDownDecoratorProps(
                        baseStyle: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 10,
                          ),
                          labelStyle: const TextStyle(fontSize: 12),
                          labelText: 'Pilih Varian Body',
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      popupProps: PopupPropsMultiSelection.menu(
                        showSearchBox: true,
                        checkBoxBuilder:
                            (context, item, isDisabled, isSelected) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Checkbox(
                                  value: isSelected,
                                  onChanged: isDisabled ? null : (_) {},
                                ),
                              );
                            },
                        searchFieldProps: TextFieldProps(
                          autofocus: true,
                          style: TextStyle(fontSize: 13, height: 1.0),
                          decoration: InputDecoration(
                            constraints: BoxConstraints(maxHeight: 42),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10,
                            ),
                            hintStyle: TextStyle(fontSize: 13, height: 1.0),
                            hintText: "Cari varian...",
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                        menuProps: const MenuProps(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        itemBuilder: (context, item, isSelected, isDisabled) {
                          return Container(
                            padding: const EdgeInsets.fromLTRB(10, 0, 16, 0),
                            height: 30,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.0,
                                      color: isDisabled
                                          ? Colors.grey
                                          : Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      validator: (items) => (items == null || items.isEmpty)
                          ? 'Wajib pilih varian'
                          : null,
                    );
                  },
                ),
              ),
              SizedBox(width: 16),
              // 3. Tombol Tambah
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
                    vertical: 14,
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
