// File: lib/elements/home/widgets/gambar/gambar_header_info.dart

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/transaksi.dart';
import 'package:master_gambar/elements/home/providers/input_gambar_providers.dart';
import 'package:master_gambar/elements/home/providers/page_state_provider.dart';
import '../../../../app/core/notifiers/refresh_notifier.dart';
import '../../../../data/models/option_item.dart';

class GambarHeaderInfo extends ConsumerWidget {
  final Transaksi? transaksi;

  const GambarHeaderInfo({super.key, this.transaksi});

  void _resetAndRefresh(BuildContext context, WidgetRef ref) {
    ref.read(isProcessingProvider.notifier).state = false;
    ref.read(deskripsiOptionalProvider.notifier).state = '';
    ref.read(descSpaceProvider.notifier).state = 0;
    ref.read(jumlahGambarProvider.notifier).state = 1;
    ref.read(pihakPenyetujuanProvider.notifier).state = 'vendor';
    ref.invalidate(gambarUtamaSelectionProvider);
    ref.invalidate(varianBodyStatusOptionsProvider);
    ref.read(refreshNotifierProvider.notifier).refresh();
    ref.watch(kelistrikanInfoProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Memuat ulang data pilihan...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditMode = ref.watch(isEditModeProvider);
    final pihakPenyetujuan = ref.watch(pihakPenyetujuanProvider);
    final isCustomerPenyetuju = pihakPenyetujuan == 'customer';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTransaksiDropdownSearch(context, ref),
                const SizedBox(width: 16),
                _buildInfoField(
                  context,
                  'Type Engine',
                  transaksi?.aTypeEngine.typeEngine ?? '-',
                ),
                const SizedBox(width: 16),
                _buildInfoField(context, 'Merk', transaksi?.bMerk.merk ?? '-'),
                const SizedBox(width: 16),
                _buildInfoField(
                  context,
                  'Type Chassis',
                  transaksi?.cTypeChassis.typeChassis ?? '-',
                ),
                const SizedBox(width: 16),
                _buildInfoField(
                  context,
                  'Jenis Kendaraan',
                  transaksi?.dJenisKendaraan.jenisKendaraan ?? '-',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildInfoField(
                  context,
                  'Customer',
                  transaksi?.customer.namaPt ?? '-',
                ),
                const SizedBox(width: 16),
                _buildInfoField(
                  context,
                  'Jenis Pengajuan',
                  transaksi?.fPengajuan.jenisPengajuan ?? '-',
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: IgnorePointer(
                    ignoring:
                        !isEditMode ||
                        transaksi == null, // Kunci jika bukan edit mode / null
                    child: Opacity(
                      opacity: (isEditMode && transaksi != null) ? 1.0 : 0.4,
                      child: _buildPihakPenyetujuanDropdown(context, ref),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // --- DROPDOWN LAMA: PEMERIKSA ---
                Expanded(
                  child: IgnorePointer(
                    // Kunci jika bukan edit mode ATAU jika pihak penyetujuan = customer
                    ignoring:
                        !isEditMode || isCustomerPenyetuju || transaksi == null,
                    child: Opacity(
                      // Redupkan jika dikunci
                      opacity:
                          (isEditMode &&
                              !isCustomerPenyetuju &&
                              transaksi != null)
                          ? 1.0
                          : 0.4,
                      child: _buildPemeriksaDropdown(
                        context,
                        ref,
                        isCustomerPenyetuju,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // --- DROPDOWN JUMLAH GAMBAR & REFRESH ---
                Expanded(
                  flex: 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 16),
                      // Disable/Enable Jumlah Gambar
                      Expanded(
                        child: IgnorePointer(
                          ignoring: !isEditMode || transaksi == null,
                          child: Opacity(
                            opacity: (isEditMode && transaksi != null)
                                ? 1.0
                                : 0.4,
                            child: _buildJumlahGambarDropdown(context, ref),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Disable Reload button jika locked
                      if (isEditMode && transaksi != null)
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Muat Ulang Pilihan',
                          onPressed: () => _resetAndRefresh(context, ref),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransaksiDropdownSearch(BuildContext context, WidgetRef ref) {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No. ID',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 32,
            child: DropdownSearch<Transaksi>(
              selectedItem: transaksi,
              items: (String filter, _) async {
                return await ref.read(
                  inputGambarTransaksiSearchProvider(filter).future,
                );
              },
              compareFn: (i1, i2) => i1.id == i2.id,
              itemAsString: (item) => item.id,
              filterFn: (item, filter) {
                if (filter.isEmpty) return true;
                final q = filter.toLowerCase();
                return item.id.toLowerCase().contains(q) ||
                    item.customer.namaPt.toLowerCase().contains(q) ||
                    item.aTypeEngine.typeEngine.toLowerCase().contains(q) ||
                    item.bMerk.merk.toLowerCase().contains(q) ||
                    item.cTypeChassis.typeChassis.toLowerCase().contains(q) ||
                    item.dJenisKendaraan.jenisKendaraan.toLowerCase().contains(
                      q,
                    ) ||
                    item.fPengajuan.jenisPengajuan.toLowerCase().contains(q);
              },
              onChanged: (selected) {
                if (selected != null) {
                  ref.read(pageStateProvider.notifier).state = PageState(
                    pageIndex: 1,
                    data: selected,
                  );
                }
              },
              decoratorProps: DropDownDecoratorProps(
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Pilih ID...',
                  hintStyle: const TextStyle(fontSize: 12),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                fit: FlexFit.loose,
                // --- KONTROL LEBAR & TINGGI MENU POPUP (LEBIH LEBAR KE KANAN DARI FIELD DROPDOWN) ---
                constraints: const BoxConstraints(
                  maxHeight: 380,
                  minWidth: 1200,
                  maxWidth: 1500,
                ),
                searchFieldProps: const TextFieldProps(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText:
                        'Cari No. ID, Customer, Engine, Merk, Chassis, Jenis, atau Pengajuan...',
                    hintStyle: TextStyle(fontSize: 12),
                    prefixIcon: Icon(Icons.search, size: 18),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                ),
                itemBuilder: (context, item, isSelected, isDisabled) {
                  final colorScheme = Theme.of(context).colorScheme;
                  return Container(
                    // =========================================================================
                    // --- KONTROL JARAK ANTAR KONTEN / PADDING DI DALAM DROPDOWN (SANGAT KECIL) ---
                    // Anda bisa mengubah angka padding di bawah ini untuk mengatur kerapatan/space
                    // =========================================================================
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: colorScheme.outline.withAlpha(50),
                          width: 0.5,
                        ),
                      ),
                      color: isSelected
                          ? colorScheme.primary.withAlpha(35)
                          : null,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // No. ID
                        SizedBox(
                          width: 85,
                          child: Text(
                            item.id,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        // --- KONTROL JARAK HORIZONTAL ANTAR KOLOM ---
                        const SizedBox(width: 4),
                        // Customer
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.customer.namaPt,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Type Engine
                        Expanded(
                          flex: 1,
                          child: Text(
                            item.aTypeEngine.typeEngine,
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurface.withAlpha(190),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Merk
                        Expanded(
                          flex: 2,
                          child: Text(
                            item.bMerk.merk,
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurface.withAlpha(190),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Type Chassis
                        Expanded(
                          flex: 5,
                          child: Text(
                            item.cTypeChassis.typeChassis,
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurface.withAlpha(190),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Jenis Kendaraan
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.dJenisKendaraan.jenisKendaraan,
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurface.withAlpha(190),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Jenis Pengajuan
                        Expanded(
                          flex: 2,
                          child: Text(
                            item.fPengajuan.jenisPengajuan,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface.withAlpha(190),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: SelectableText(
              value,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _dropdownTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(fontSize: 13, color: theme.colorScheme.onSurface);
  }

  // --- WIDGET BARU: DROPDOWN PIHAK PENYETUJUAN ---
  Widget _buildPihakPenyetujuanDropdown(BuildContext context, WidgetRef ref) {
    final selectedValue = ref.watch(pihakPenyetujuanProvider);
    final textStyle = _dropdownTextStyle(context);

    return DropdownButtonFormField<String>(
      // ignore: deprecated_member_use
      value: selectedValue,
      itemHeight: 30,
      style: textStyle,
      dropdownColor: Theme.of(context).colorScheme.surface,
      decoration: InputDecoration(
        labelStyle: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        labelText: 'Pihak Penyetujuan',
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
      ),
      items: [
        DropdownMenuItem(
          value: 'vendor',
          child: Text('Internal (Vendor)', style: textStyle),
        ),
        DropdownMenuItem(
          value: 'customer',
          child: Text('Eksternal (Customer)', style: textStyle),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          ref.read(pihakPenyetujuanProvider.notifier).state = value;

          // Opsional: Jika user pilih 'customer', kita hapus (null-kan) pilihan pemeriksa internalnya.
          // Jika mau dibiarkan tetap ada (meski gak dipakai) ya tidak apa-apa, tapi lebih bersih jika di-null-kan.
          if (value == 'customer') {
            ref.read(pemeriksaIdProvider.notifier).state = null;
          }
        }
      },
    );
  }

  Widget _buildJumlahGambarDropdown(BuildContext context, WidgetRef ref) {
    final selectedJumlah = ref.watch(jumlahGambarProvider);
    final jenisPengajuan = (transaksi?.fPengajuan.jenisPengajuan ?? '')
        .toUpperCase();
    final textStyle = _dropdownTextStyle(context);
    List<int> options = [1, 2, 3, 4];
    if (jenisPengajuan == 'VARIAN') {
      options = [1, 2, 3];
    }
    if (!options.contains(selectedJumlah)) {
      Future.microtask(() {
        ref.read(jumlahGambarProvider.notifier).state = options.last;
      });
    }
    return DropdownButtonFormField<int>(
      // ignore: deprecated_member_use
      value: options.contains(selectedJumlah) ? selectedJumlah : options.last,
      itemHeight: 30,
      style: textStyle,
      dropdownColor: Theme.of(context).colorScheme.surface,
      decoration: InputDecoration(
        labelStyle: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        labelText: 'Jumlah Gambar',
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
      ),
      items: options
          .map(
            (e) => DropdownMenuItem<int>(
              value: e,
              child: Text(e.toString(), style: textStyle),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          ref.read(jumlahGambarProvider.notifier).state = value;
        }
      },
    );
  }

  Widget _buildPemeriksaDropdown(
    BuildContext context,
    WidgetRef ref,
    bool isCustomerPenyetuju,
  ) {
    final pemeriksaOptionsAsync = ref.watch(pemeriksaOptionsProvider);
    final selectedId = ref.watch(pemeriksaIdProvider);

    ref.listen<AsyncValue<List<OptionItem>>>(pemeriksaOptionsProvider, (
      previous,
      next,
    ) {
      if (next is AsyncData && previous is! AsyncData) {
        final options = next.value;
        // Jangan set otomatis jika pihak penyetujuannya adalah customer
        if (options != null &&
            options.isNotEmpty &&
            ref.read(pemeriksaIdProvider) == null &&
            !isCustomerPenyetuju) {
          ref.read(pemeriksaIdProvider.notifier).state =
              options.first.id as int?;
        }
      }
    });

    return pemeriksaOptionsAsync.when(
      data: (items) {
        if (items.isNotEmpty && selectedId == null && !isCustomerPenyetuju) {
          Future.microtask(() {
            if (ref.read(pemeriksaIdProvider) == null) {
              ref.read(pemeriksaIdProvider.notifier).state =
                  items.first.id as int?;
            }
          });
        }

        final textStyle = _dropdownTextStyle(context);

        return DropdownButtonFormField<int>(
          // ignore: deprecated_member_use
          value: selectedId, // Jika null, akan menampilkan 'hint'
          itemHeight: 30,
          style: textStyle,
          dropdownColor: Theme.of(context).colorScheme.surface,
          hint: Text(
            'Pilih Pemeriksa',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          decoration: InputDecoration(
            labelStyle: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            labelText: 'Pemeriksa Internal',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
          ),
          items: items
              .map(
                (e) => DropdownMenuItem<int>(
                  value: e.id as int,
                  child: Text(e.name, style: textStyle),
                ),
              )
              .toList(),
          onChanged: (value) {
            ref.read(pemeriksaIdProvider.notifier).state = value;
          },
          // LOGIKA BARU VALIDASI:
          // Wajib dipilih HANYA jika pihak penyetujuan BUKAN customer
          validator: (value) {
            if (!isCustomerPenyetuju && value == null) {
              return 'Wajib dipilih';
            }
            return null;
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const Tooltip(
        message: 'Error memuat pemeriksa',
        child: Icon(Icons.error),
      ),
    );
  }
}
