// File: lib/elements/home/widgets/gambar/gambar_utama_row.dart

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/option_item.dart';
import 'package:master_gambar/data/models/transaksi.dart';
import 'package:master_gambar/elements/home/providers/input_gambar_providers.dart';

class GambarUtamaRow extends ConsumerWidget {
  final int index;
  final Transaksi transaksi;
  final int totalHalaman;
  final VoidCallback onPreviewPressed;
  final int pageNumber;

  const GambarUtamaRow({
    super.key,
    required this.index,
    required this.transaksi,
    required this.totalHalaman,
    required this.onPreviewPressed,
    required this.pageNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pemeriksaId = ref.watch(pemeriksaIdProvider);
    final selections = ref.watch(gambarUtamaSelectionProvider);
    final selection = selections[index];
    final judulOptions = ref.watch(judulGambarOptionsProvider);

    // 1. Siapkan Parameter Default (Search Kosong)
    final defaultParams = VarianFilterParams(
      search: '',
      masterDataId: transaksi.masterDataId,
    );

    // 2. Watch provider dengan parameter default untuk menangani state Loading saat Refresh
    final varianBodyOptionsAsync = ref.watch(
      varianBodyStatusOptionsProvider(defaultParams),
    );

    final bool isRowComplete =
        selection.judulId != null &&
        selection.varianBodyId != null &&
        pemeriksaId != null;
    final isLoading = ref.watch(isProcessingProvider);
    return Row(
      children: [
        SizedBox(width: 150, child: Text('Gambar Utama ${index + 1}:')),

        // 1. Dropdown Judul (Tetap pakai standar atau ubah ke Search juga boleh)
        Expanded(
          flex: 2,
          child: judulOptions.when(
            data: (items) => DropdownButtonFormField<int>(
              value: selection.judulId,
              isDense: true,
              hint: const Text('Pilih Judul'),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
              ),
              items: items
                  .map(
                    (e) => DropdownMenuItem<int>(
                      value: e.id as int,
                      child: Text(e.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                ref
                    .read(gambarUtamaSelectionProvider.notifier)
                    .updateSelection(index, judulId: value);
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => const Text('Error Judul'),
          ),
        ),

        const SizedBox(width: 10),
        // 2. Dropdown Varian Body (DIBUNGKUS .when)
        Expanded(
          flex: 4,
          child: varianBodyOptionsAsync.when(
            skipLoadingOnRefresh: false,
            data: (defaultItems) {
              // Cari item yang sedang dipilih dari daftar yang baru dimuat agar tampilannya persisten
              final selectedOption = defaultItems
                  .where((e) => e.id == selection.varianBodyId)
                  .firstOrNull;

              return DropdownSearch<OptionItem>(
                // Async Items (tetap dipanggil saat user mengetik)
                items: (String filter, _) {
                  final params = VarianFilterParams(
                    search: filter,
                    masterDataId: transaksi.masterDataId,
                  );
                  return ref.read(
                    varianBodyStatusOptionsProvider(params).future,
                  );
                },

                itemAsString: (OptionItem item) => item.name,
                compareFn: (i1, i2) => i1.id == i2.id,

                // Pasang item yang ditemukan (atau null jika tidak ada di list default)
                selectedItem: selectedOption,

                onChanged: (OptionItem? item) {
                  ref
                      .read(gambarUtamaSelectionProvider.notifier)
                      .updateSelection(index, varianBodyId: item?.id as int?);
                },

                decoratorProps: const DropDownDecoratorProps(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 0,
                    ),
                    hintText: 'Pilih Varian',
                  ),
                ),

                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: const TextFieldProps(
                    decoration: InputDecoration(
                      hintText: "Cari Varian...",
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  itemBuilder: (context, item, isSelected, isDisabled) {
                    final hasGambar = item.hasGambar;
                    return ListTile(
                      title: Text(
                        item.name,
                        style: TextStyle(
                          color: hasGambar ? Colors.black : Colors.red,
                          fontWeight: hasGambar
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      trailing: hasGambar
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            )
                          : const Text(
                              "Belum Upload",
                              style: TextStyle(color: Colors.red, fontSize: 10),
                            ),
                    );
                  },
                ),
              );
            },
            // TAMPILAN SAAT LOADING (Saat tombol Refresh ditekan)
            loading: () => const SizedBox(
              height: 48, // Tinggi standar input field
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => const SizedBox(
              height: 48,
              child: Center(
                child: Text(
                  'Error Varian',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // 3. Indikator Halaman
        SizedBox(
          width: 70,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.yellow.shade200,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey),
            ),
            child: Center(child: Text('$pageNumber/$totalHalaman')),
          ),
        ),

        const SizedBox(width: 10),

        // 4. Tombol Preview
        SizedBox(
          width: 170,
          child: ElevatedButton(
            onPressed: isRowComplete && !isLoading ? onPreviewPressed : null,
            child: const Text('Preview Gambar'),
          ),
        ),
      ],
    );
  }
}
