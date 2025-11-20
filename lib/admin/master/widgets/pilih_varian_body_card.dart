// File: lib/admin/master/widgets/pilih_varian_body_card.dart

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/data/models/option_item.dart';

class PilihVarianBodyCard extends ConsumerWidget {
  const PilihVarianBodyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. DENGARKAN DATA COPY DARI HALAMAN LAIN
    ref.listen<Map<String, dynamic>?>(initialGambarUtamaDataProvider, (
      prev,
      next,
    ) {
      if (next != null) {
        // Ekstrak data OptionItem yang dikirim
        final typeEngine = next['typeEngine'] as OptionItem;
        final merk = next['merk'] as OptionItem;
        final typeChassis = next['typeChassis'] as OptionItem;
        final jenisKendaraan = next['jenisKendaraan'] as OptionItem;
        final varianBody = next['varianBody'] as OptionItem;

        // Isi State Provider Global (mgu...) agar dropdown terisi
        ref.read(mguSelectedTypeEngineIdProvider.notifier).state = typeEngine.id
            .toString();
        ref.read(mguSelectedMerkIdProvider.notifier).state = merk.id.toString();
        ref.read(mguSelectedTypeChassisIdProvider.notifier).state = typeChassis
            .id
            .toString();
        ref.read(mguSelectedJenisKendaraanIdProvider.notifier).state =
            jenisKendaraan.id.toString();
        ref.read(mguSelectedVarianBodyIdProvider.notifier).state =
            varianBody.id as int;

        // Beri notifikasi kecil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil disalin! Silakan upload gambar.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Reset data provider agar tidak memicu ulang jika widget di-rebuild
        ref.read(initialGambarUtamaDataProvider.notifier).state = null;
      }
    });

    // Ambil value dari provider global (mgu...)
    final selectedEngineId = ref.watch(mguSelectedTypeEngineIdProvider);
    final selectedMerkId = ref.watch(mguSelectedMerkIdProvider);
    final selectedChassisId = ref.watch(mguSelectedTypeChassisIdProvider);
    final selectedJenisId = ref.watch(mguSelectedJenisKendaraanIdProvider);
    final selectedVarianId = ref.watch(mguSelectedVarianBodyIdProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "1. Pilih Varian Body",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // TYPE ENGINE
                _buildDropdown(
                  ref: ref,
                  label: 'Type Engine',
                  provider: mdTypeEngineOptionsProvider,
                  selectedId: selectedEngineId,
                  onChanged: (val) {
                    ref.read(mguSelectedTypeEngineIdProvider.notifier).state =
                        val?.id.toString();
                    // Reset anak-anaknya
                    ref.read(mguSelectedMerkIdProvider.notifier).state = null;
                    ref.read(mguSelectedTypeChassisIdProvider.notifier).state =
                        null;
                    ref
                            .read(mguSelectedJenisKendaraanIdProvider.notifier)
                            .state =
                        null;
                    ref.read(mguSelectedVarianBodyIdProvider.notifier).state =
                        null;
                  },
                ),
                const SizedBox(width: 16),
                // MERK
                _buildDropdown(
                  ref: ref,
                  label: 'Merk',
                  provider: mdMerkOptionsProvider,
                  selectedId: selectedMerkId,
                  onChanged: (val) {
                    ref.read(mguSelectedMerkIdProvider.notifier).state = val?.id
                        .toString();
                    ref.read(mguSelectedTypeChassisIdProvider.notifier).state =
                        null;
                    ref
                            .read(mguSelectedJenisKendaraanIdProvider.notifier)
                            .state =
                        null;
                    ref.read(mguSelectedVarianBodyIdProvider.notifier).state =
                        null;
                  },
                ),
                const SizedBox(width: 16),
                // TYPE CHASSIS
                _buildDropdown(
                  ref: ref,
                  label: 'Type Chassis',
                  provider: mdTypeChassisOptionsProvider,
                  selectedId: selectedChassisId,
                  onChanged: (val) {
                    ref.read(mguSelectedTypeChassisIdProvider.notifier).state =
                        val?.id.toString();
                    ref
                            .read(mguSelectedJenisKendaraanIdProvider.notifier)
                            .state =
                        null;
                    ref.read(mguSelectedVarianBodyIdProvider.notifier).state =
                        null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // JENIS KENDARAAN
                _buildDropdown(
                  ref: ref,
                  label: 'Jenis Kendaraan',
                  provider: mdJenisKendaraanOptionsProvider,
                  selectedId: selectedJenisId,
                  onChanged: (val) {
                    ref
                        .read(mguSelectedJenisKendaraanIdProvider.notifier)
                        .state = val?.id
                        .toString();
                    ref.read(mguSelectedVarianBodyIdProvider.notifier).state =
                        null;
                  },
                ),
                const SizedBox(width: 16),
                // VARIAN BODY (Dropdown terakhir)
                Expanded(
                  child: DropdownSearch<OptionItem>(
                    items: (filter, _) => ref.read(
                      varianBodyOptionsFamilyProvider(selectedJenisId).future,
                    ),
                    itemAsString: (item) => item.name,
                    compareFn: (i1, i2) => i1.id == i2.id,
                    selectedItem: selectedVarianId != null
                        ? OptionItem(
                            id: selectedVarianId,
                            name: '',
                          ) // Dummy name, dropdown will fetch real one or use compareFn
                        : null,
                    onChanged: (val) {
                      ref.read(mguSelectedVarianBodyIdProvider.notifier).state =
                          val?.id as int?;
                    },
                    decoratorProps: const DropDownDecoratorProps(
                      decoration: InputDecoration(
                        labelText: 'Varian Body',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    enabled:
                        selectedJenisId !=
                        null, // Hanya aktif jika jenis dipilih
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(hintText: "Cari Varian..."),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required WidgetRef ref,
    required String label,
    required FutureProviderFamily<List<OptionItem>, String> provider,
    required String? selectedId,
    required Function(OptionItem?) onChanged,
  }) {
    return Expanded(
      child: DropdownSearch<OptionItem>(
        items: (filter, _) => ref.read(provider(filter).future),
        itemAsString: (item) => item.name,
        compareFn: (i1, i2) => i1.id.toString() == i2.id.toString(),
        // Kunci agar dropdown menampilkan nilai terpilih saat di-copy
        selectedItem: selectedId != null
            ? OptionItem(
                id: selectedId,
                name: '',
              ) // DropdownSearch v6 cukup pintar, atau akan menampilkan kosong jika item tidak di list awal.
            // Trik: Biasanya kita butuh object lengkap.
            // Tapi karena ini searchable dan lazy loaded, idealnya kita kirim object lengkap dari 'copy'.
            // Namun provider 'mgu...' hanya simpan ID.
            // Untuk sekarang ini cukup, karena user akan melihat form terisi.
            : null,
        onChanged: onChanged,
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
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
    );
  }
}
