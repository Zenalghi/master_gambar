import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:master_gambar/data/models/option_item.dart';

class PilihMasterDataCard extends ConsumerStatefulWidget {
  final bool isEditMode;
  const PilihMasterDataCard({super.key, this.isEditMode = false});

  @override
  ConsumerState<PilihMasterDataCard> createState() =>
      _PilihMasterDataCardState();
}

class _PilihMasterDataCardState extends ConsumerState<PilihMasterDataCard> {
  OptionItem? _selectedMasterData;

  @override
  void initState() {
    super.initState();
    // Cek data awal (untuk fitur Copy)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pendingData = ref.read(initialGambarUtamaDataProvider);
      if (pendingData != null && pendingData['masterData'] != null) {
        final masterItem = pendingData['masterData'] as OptionItem;
        setState(() {
          _selectedMasterData = masterItem;
        });
        // Set Provider
        ref.read(mguSelectedMasterDataIdProvider.notifier).state =
            masterItem.id as int?;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen perubahan dari luar (misal tombol Copy ditekan)
    ref.listen<Map<String, dynamic>?>(initialGambarUtamaDataProvider, (
      prev,
      next,
    ) {
      if (next != null && next['masterData'] != null) {
        final masterItem = next['masterData'] as OptionItem;
        setState(() {
          _selectedMasterData = masterItem;
        });
        ref.read(mguSelectedMasterDataIdProvider.notifier).state =
            masterItem.id as int?;
      } else if (next == null) {
        // Reset
        setState(() => _selectedMasterData = null);
        ref.read(mguSelectedMasterDataIdProvider.notifier).state = null;
      }
    });

    return Card(
      child: IgnorePointer(
        ignoring: widget.isEditMode, // Disable saat Edit
        child: Opacity(
          opacity: widget.isEditMode ? 0.6 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "1. Pilih Data Kendaraan (Master Data)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 5),

                DropdownSearch<OptionItem>(
                  items: (String filter, _) => ref
                      .read(masterDataRepositoryProvider)
                      .getMasterDataOptions(filter),
                  itemAsString: (item) => item.name,
                  compareFn: (item1, item2) => item1.id == item2.id,
                  selectedItem: _selectedMasterData,
                  onChanged: (OptionItem? item) {
                    setState(() => _selectedMasterData = item);
                    ref.read(mguSelectedMasterDataIdProvider.notifier).state =
                        item?.id as int?;
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
                      labelText:
                          'Pilih Master Data (Engine / Merk / Chassis / Jenis)',
                      border: OutlineInputBorder(),
                      isDense: true,
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
                        hintText: "Cari...",
                        prefixIcon: Icon(Icons.search),
                      ),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
