// File: lib/elements/home/widgets/detail_skrb/detail_skrb_top_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:master_gambar/data/models/skrb.dart';
import '../../providers/page_state_provider.dart';
import '../../providers/skrb_providers.dart';
import '../../screens/detail_skrb_screen.dart';

class DetailSkrbTopBar extends ConsumerWidget {
  final int? skrbId;
  final Future<void> Function(Skrb skrb)? onMerge;
  final VoidCallback onClosePreview;

  const DetailSkrbTopBar({
    super.key,
    required this.skrbId,
    required this.onMerge,
    required this.onClosePreview,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final skrbListAsync = ref.watch(skrbListProvider);

    Skrb? activeSkrb;
    final skrbDetailAsync = skrbId != null
        ? ref.watch(skrbDetailProvider(skrbId!))
        : null;

    skrbDetailAsync?.maybeWhen(
      data: (item) => activeSkrb = item,
      orElse: () {},
    );
    if (activeSkrb == null && skrbId != null) {
      skrbListAsync.maybeWhen(
        data: (list) {
          try {
            activeSkrb = list.firstWhere((e) => e.id == skrbId);
          } catch (_) {}
        },
        orElse: () {},
      );
    }

    Widget badgeWidget = const SizedBox.shrink();
    if (activeSkrb != null) {
      final faseBadgeText = activeSkrb!.fase == 1
          ? '(BARU / DRAFT)'
          : (activeSkrb!.fase == 2 ? '(TERSIMPAN & TERKUNCI)' : '(MODE EDIT)');
      final badgeColor = activeSkrb!.fase == 1
          ? Colors.blue
          : (activeSkrb!.fase == 2 ? Colors.green : Colors.orange);

      badgeWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: badgeColor.withAlpha(30),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: badgeColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              activeSkrb!.fase == 2 ? Icons.lock : Icons.lock_open,
              size: 16,
              color: badgeColor,
            ),
            const SizedBox(width: 6),
            Text(
              faseBadgeText,
              style: TextStyle(
                color: badgeColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: Colors.grey.withAlpha(50))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 22, color: Colors.blue),
            tooltip: 'Kembali ke Tabel Permohonan SKRB',
            onPressed: () async {
              final canProceed =
                  await DetailSkrbScreen.checkAndConfirmUnsavedChanges(
                    context,
                    ref,
                    onSave: (activeSkrb != null && onMerge != null)
                        ? () => onMerge!(activeSkrb!)
                        : null,
                  );
              if (canProceed) {
                ref.read(pageStateProvider.notifier).state = PageState(
                  pageIndex: 2,
                );
              }
            },
          ),
          const SizedBox(width: 6),
          Icon(Icons.description, color: colorScheme.primary, size: 22),
          const SizedBox(width: 6),
          const Text(
            'Detail SKRB :',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 36,
              child: skrbListAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text(
                  'Error memuat daftar SKRB: $err',
                  style: const TextStyle(color: Colors.red, fontSize: 11),
                ),
                data: (list) => DropdownSearch<Skrb>(
                  items: (String filter, _) {
                    final query = filter.trim().toLowerCase();
                    if (query.isEmpty) {
                      return list.take(30).toList();
                    }
                    return list.where((item) {
                      return item.idSkrb.toLowerCase().contains(query) ||
                          item.transaksiId.toLowerCase().contains(query) ||
                          item.customerName.toLowerCase().contains(query) ||
                          item.merk.toLowerCase().contains(query) ||
                          item.typeChassis.toLowerCase().contains(query);
                    }).toList();
                  },
                  itemAsString: (item) =>
                      'ID SKRB : ${item.idSkrb} | ID DWG : ${item.transaksiId} || Customer : ${item.customerName} || Merk : ${item.merk} | Type : ${item.typeChassis} | Jenis : ${item.jenisKendaraan} | Pengajuan : ${item.jenisPengajuan}',
                  compareFn: (i1, i2) => i1.id == i2.id,
                  selectedItem: activeSkrb,
                  dropdownBuilder: (ctx, selectedItem) {
                    if (selectedItem == null) {
                      return const Text('', style: TextStyle(fontSize: 12));
                    }
                    final text =
                        'ID SKRB : ${selectedItem.idSkrb} | ID DWG : ${selectedItem.transaksiId} || Customer : ${selectedItem.customerName} || Merk : ${selectedItem.merk} | Type : ${selectedItem.typeChassis} | Jenis : ${selectedItem.jenisKendaraan} | Pengajuan : ${selectedItem.jenisPengajuan}';
                    return SelectableText(
                      text,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                  onChanged: (item) async {
                    if (item != null && item.id != skrbId) {
                      final canProceed =
                          await DetailSkrbScreen.checkAndConfirmUnsavedChanges(
                            context,
                            ref,
                            onSave: (activeSkrb != null && onMerge != null)
                                ? () => onMerge!(activeSkrb!)
                                : null,
                          );
                      if (canProceed) {
                        onClosePreview();
                        ref.invalidate(skrbDetailProvider(item.id));
                        ref.read(pageStateProvider.notifier).state = PageState(
                          pageIndex: 3,
                          skrbId: item.id,
                        );
                      }
                    }
                  },
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: 'Pilih SKRB (ID SKRB / ID DWG / Customer)...',
                      labelStyle: const TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                    ),
                  ),
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: const TextFieldProps(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText:
                            'Ketik untuk mencari seluruh ID SKRB / DWG / Customer...', //30 list
                        hintStyle: TextStyle(fontSize: 11),
                        prefixIcon: Icon(Icons.search, size: 18),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                      ),
                    ),
                    itemBuilder: (ctx, item, isSel, isDis) => ListTile(
                      dense: true,
                      title: Text(
                        'ID SKRB : ${item.idSkrb} | ID DWG : ${item.transaksiId}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      subtitle: Text(
                        'Customer : ${item.customerName} | ${item.merk} | ${item.typeChassis}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          badgeWidget,
        ],
      ),
    );
  }
}
