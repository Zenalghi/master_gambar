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

    final isEditMode = ref.watch(isEditModeProvider);

    return Row(
      children: [
        SizedBox(width: 150, child: Text('Gambar Utama ${index + 1}:')),

        Expanded(
          flex: 2,
          child: IgnorePointer(
            ignoring: !isEditMode,
            child: Opacity(
              opacity: isEditMode ? 1.0 : 0.6,
              child: judulOptions.when(
                data: (items) {
                  // Cari object OptionItem yang sesuai dengan ID yang tersimpan
                  final selectedOption = items
                      .where((e) => e.id == selection.judulId)
                      .firstOrNull;

                  return DropdownSearch<OptionItem>(
                    // Data sudah diload oleh provider di atas, jadi langsung pakai list 'items'
                    items: (filter, _) => items
                        .where(
                          (e) => e.name.toLowerCase().contains(
                            filter.toLowerCase(),
                          ),
                        )
                        .toList(),

                    itemAsString: (OptionItem item) => item.name,
                    compareFn: (i1, i2) => i1.id == i2.id,
                    selectedItem: selectedOption,

                    onChanged: (OptionItem? item) {
                      ref
                          .read(gambarUtamaSelectionProvider.notifier)
                          .updateSelection(index, judulId: item?.id as int?);
                    },

                    // TAMPILAN FIELD (Kecil & Padat)
                    decoratorProps: const DropDownDecoratorProps(
                      baseStyle: TextStyle(fontSize: 13, height: 1.0),
                      decoration: InputDecoration(
                        hintText: 'Pilih Judul',
                        border: OutlineInputBorder(),
                        constraints: BoxConstraints(
                          maxHeight: 32,
                        ), // Tinggi Field 32px
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        isDense: true,
                      ),
                    ),

                    // TAMPILAN POPUP (Custom Item Builder untuk tinggi 30px)
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: const TextFieldProps(
                        autofocus: true,
                        style: TextStyle(fontSize: 13, height: 1.0),
                        decoration: InputDecoration(
                          constraints: BoxConstraints(maxHeight: 32),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 0,
                          ),
                          hintText: "Cari Judul...",
                          prefixIcon: Icon(Icons.search, size: 18),
                        ),
                      ),
                      // --- INI KUNCINYA UNTUK LIST ITEM PENDEK ---
                      itemBuilder: (context, item, isSelected, isDisabled) {
                        return Container(
                          height: 30, // Paksa tinggi item jadi 30px
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.centerLeft,
                          color: isSelected
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
                              : null,
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                      // -------------------------------------------
                      menuProps: const MenuProps(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),

                    validator: (item) =>
                        item == null && selection.judulId == null
                        ? 'Wajib'
                        : null,
                  );
                },
                loading: () => const SizedBox(
                  height: 32,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => const SizedBox(
                  height: 32,
                  child: Center(
                    child: Text(
                      'Error',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),
        // 2. Dropdown Varian Body (DIBUNGKUS .when)
        Expanded(
          flex: 4,
          child: IgnorePointer(
            ignoring: !isEditMode,
            child: Opacity(
              opacity: isEditMode ? 1.0 : 0.6,
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
                          .updateSelection(
                            index,
                            varianBodyId: item?.id as int?,
                          );
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
                        border: OutlineInputBorder(),
                        hintText: 'Pilih Varian',
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
                          hintText: "Cari Varian...",
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      itemBuilder: (context, item, isSelected, isDisabled) {
                        final hasGambar = item.hasGambar;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 0,
                          ),
                          height: 30, // tinggi item
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // NAMA ITEM
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.0,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : (hasGambar
                                              ? FontWeight.normal
                                              : FontWeight.bold),
                                    color: hasGambar
                                        ? (isSelected
                                              ? Theme.of(context).primaryColor
                                              : Colors.black87)
                                        : Colors.red,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // TRAILING (ICON / TEKS)
                              hasGambar
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 14,
                                    )
                                  : const Text(
                                      "Belum Upload",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 10,
                                      ),
                                    ),
                            ],
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
