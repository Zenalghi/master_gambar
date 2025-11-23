// File: lib/admin/master/widgets/pilih_varian_body_card.dart

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:master_gambar/data/models/option_item.dart';
import 'package:master_gambar/data/providers/api_endpoints.dart';
import 'package:master_gambar/app/core/providers.dart';

class PilihVarianBodyCard extends ConsumerWidget {
  const PilihVarianBodyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. LOGIKA COPY-PASTE DARI TABEL STATUS
    ref.listen<Map<String, dynamic>?>(initialGambarUtamaDataProvider, (
      prev,
      next,
    ) {
      if (next != null) {
        // (Logika copy-paste bisa dikembangkan nanti jika diperlukan)
      }
    });

    final selectedMasterDataId = ref.watch(mguSelectedMasterDataIdProvider);

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

            // 1. DROPDOWN MASTER DATA (Engine / Merk / Chassis / Jenis)
            DropdownSearch<OptionItem>(
              items: (String filter, _) => ref
                  .read(masterDataRepositoryProvider)
                  .getMasterDataOptions(filter),
              itemAsString: (item) => item.name,
              // --- PERBAIKAN DI SINI: Tambahkan compareFn ---
              compareFn: (item1, item2) => item1.id == item2.id,
              // --------------------------------------------
              onChanged: (OptionItem? item) {
                ref.read(mguSelectedMasterDataIdProvider.notifier).state =
                    item?.id as int?;
                // Reset Varian Body saat Master Data berubah
                ref.read(mguSelectedVarianBodyIdProvider.notifier).state = null;
                ref.read(mguSelectedVarianBodyNameProvider.notifier).state =
                    null;
              },
              selectedItem: null,
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
                    hintText: "Cari (contoh: Hino, Box)...",
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 2. DROPDOWN VARIAN BODY (Tergantung Master Data)
            DropdownSearch<OptionItem>(
              enabled:
                  selectedMasterDataId !=
                  null, // Hanya aktif jika Master Data dipilih
              items: (String filter, _) async {
                if (selectedMasterDataId == null) return [];

                // Gunakan endpoint varian body dengan filter master_data_id
                final response = await ref
                    .read(apiClientProvider)
                    .dio
                    .get(
                      '/admin/varian-body',
                      queryParameters: {
                        'search': filter,
                        'master_data_id': selectedMasterDataId,
                      },
                    );
                final List data = response.data['data'];
                return data
                    .map((e) => OptionItem(id: e['id'], name: e['varian_body']))
                    .toList();
              },
              itemAsString: (item) => item.name,
              // --- PERBAIKAN DI SINI: Tambahkan compareFn ---
              compareFn: (item1, item2) => item1.id == item2.id,
              // --------------------------------------------
              onChanged: (OptionItem? item) {
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
