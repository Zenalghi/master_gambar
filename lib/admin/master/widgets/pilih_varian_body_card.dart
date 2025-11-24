// File: lib/admin/master/widgets/pilih_varian_body_card.dart

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:master_gambar/data/models/option_item.dart';
import 'package:master_gambar/app/core/providers.dart';

class PilihVarianBodyCard extends ConsumerStatefulWidget {
  const PilihVarianBodyCard({super.key});

  @override
  ConsumerState<PilihVarianBodyCard> createState() =>
      _PilihVarianBodyCardState();
}

class _PilihVarianBodyCardState extends ConsumerState<PilihVarianBodyCard> {
  OptionItem? _selectedMasterData;
  OptionItem? _selectedVarianBody;

  // --- REVISI: Gunakan Seed Key untuk update paksa ---
  // Key ini hanya akan berubah jika data diisi dari luar (System/Navigation)
  // Bukan saat user memilih manual.
  int _dropdownSeed = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pendingData = ref.read(initialGambarUtamaDataProvider);
      if (pendingData != null) {
        _processInitialData(pendingData);
      }
    });
  }

  void _processInitialData(Map<String, dynamic> data) {
    final masterDataItem = data['masterData'] as OptionItem;
    final varianBodyItem = data['varianBody'] as OptionItem;

    setState(() {
      _selectedMasterData = masterDataItem;
      _selectedVarianBody = varianBodyItem;
      // Kita ubah key HANYA disini (saat sistem mengisi data)
      // Agar dropdown ter-reset dan menampilkan teks yang benar
      _dropdownSeed++;
    });

    ref.read(mguSelectedMasterDataIdProvider.notifier).state =
        masterDataItem.id as int;
    ref.read(mguSelectedVarianBodyIdProvider.notifier).state =
        varianBodyItem.id as int;
    ref.read(mguSelectedVarianBodyNameProvider.notifier).state =
        varianBodyItem.name;

    ref.read(initialGambarUtamaDataProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Map<String, dynamic>?>(initialGambarUtamaDataProvider, (
      prev,
      next,
    ) {
      if (next != null) {
        _processInitialData(next);
      }
    });

    final globalSelectedMasterId = ref.watch(mguSelectedMasterDataIdProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "1. Pilih Data Kendaraan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),

            // 1. DROPDOWN MASTER DATA
            DropdownSearch<OptionItem>(
              // --- FIX CRASH: Gunakan Seed Key ---
              // Key hanya berubah jika _dropdownSeed berubah (via _processInitialData)
              // Key TIDAK berubah saat user memilih item, jadi tidak crash.
              key: ValueKey('master_$_dropdownSeed'),

              items: (String filter, _) => ref
                  .read(masterDataRepositoryProvider)
                  .getMasterDataOptions(filter),
              itemAsString: (item) => item.name,
              compareFn: (item1, item2) => item1.id == item2.id,
              selectedItem: _selectedMasterData,
              onChanged: (OptionItem? item) {
                setState(() {
                  _selectedMasterData = item;
                  // Reset anak jika induk berubah
                  if (item?.id != globalSelectedMasterId) {
                    _selectedVarianBody = null;
                  }
                  // CATATAN: Jangan ubah _dropdownSeed disini!
                });

                ref.read(mguSelectedMasterDataIdProvider.notifier).state =
                    item?.id as int?;

                if (item?.id != globalSelectedMasterId) {
                  ref.read(mguSelectedVarianBodyIdProvider.notifier).state =
                      null;
                  ref.read(mguSelectedVarianBodyNameProvider.notifier).state =
                      null;
                }
              },
              decoratorProps: const DropDownDecoratorProps(
                decoration: InputDecoration(
                  labelText:
                      'Pilih Master Data (Engine / Merk / Chassis / Jenis)',
                  border: OutlineInputBorder(),
                  isDense: true,
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
            ),

            const SizedBox(height: 16),

            // 2. DROPDOWN VARIAN BODY
            DropdownSearch<OptionItem>(
              // Gunakan Seed Key juga
              key: ValueKey('varian_$_dropdownSeed'),

              enabled: globalSelectedMasterId != null,
              items: (String filter, _) async {
                if (globalSelectedMasterId == null) return [];
                final response = await ref
                    .read(apiClientProvider)
                    .dio
                    .get(
                      '/admin/varian-body',
                      queryParameters: {
                        'search': filter,
                        'master_data_id': globalSelectedMasterId,
                      },
                    );
                final List data = response.data['data'];
                return data
                    .map((e) => OptionItem(id: e['id'], name: e['varian_body']))
                    .toList();
              },
              itemAsString: (item) => item.name,
              compareFn: (item1, item2) => item1.id == item2.id,
              selectedItem: _selectedVarianBody,
              onChanged: (OptionItem? item) {
                setState(() {
                  _selectedVarianBody = item;
                });

                ref.read(mguSelectedVarianBodyIdProvider.notifier).state =
                    item?.id as int?;
                ref.read(mguSelectedVarianBodyNameProvider.notifier).state =
                    item?.name;
              },
              decoratorProps: const DropDownDecoratorProps(
                decoration: InputDecoration(
                  labelText: 'Pilih Varian Body',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              popupProps: const PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: "Cari Varian...",
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
