// File: lib/admin/master/widgets/pilih_varian_body_card.dart

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:master_gambar/data/models/option_item.dart';
// import 'package:master_gambar/data/providers/api_endpoints.dart';
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
        // Kita asumsikan 'masterDataId' dan 'varianBody' dikirim dari tabel
        // (Anda perlu update logika navigasi di DataSource tabel status nanti)

        // Jika data copy belum lengkap (masih format lama), kita skip atau handle manual.
        // Idealnya DataSource mengirim masterDataId.
        // Untuk sekarang, mari kita fokus ke input manual yang benar dulu.
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
              onChanged: (OptionItem? item) {
                ref.read(mguSelectedMasterDataIdProvider.notifier).state =
                    item?.id as int?;
                // Reset Varian Body saat Master Data berubah
                ref.read(mguSelectedVarianBodyIdProvider.notifier).state = null;
                ref.read(mguSelectedVarianBodyNameProvider.notifier).state =
                    null;
              },
              selectedItem: null, // Bisa diisi jika ada fitur copy-paste
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
                // Kita butuh endpoint khusus untuk ambil varian by master_data_id
                // Atau gunakan endpoint yang sudah ada jika parameternya cocok.
                // SEMENTARA: Kita gunakan endpoint varian body biasa, tapi idealnya difilter by master_data_id.
                // Asumsi: Backend '/options/varian-body' bisa terima filter master_data_id?
                // Jika belum, Anda mungkin perlu membuat endpoint simple: getVarianByMasterData($id).

                // Solusi Cepat: Gunakan repo existing jika endpointnya mendukung,
                // atau biarkan user ketik manual jika perlu (tapi dropdown lebih aman).

                // Mari gunakan cara manual fetch dari repository dengan query khusus
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
                // Parsing manual karena format paginated
                final List data = response.data['data'];
                return data
                    .map((e) => OptionItem(id: e['id'], name: e['varian_body']))
                    .toList();
              },
              itemAsString: (item) => item.name,
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
              popupProps: const PopupProps.menu(showSearchBox: true),
            ),
          ],
        ),
      ),
    );
  }
}
