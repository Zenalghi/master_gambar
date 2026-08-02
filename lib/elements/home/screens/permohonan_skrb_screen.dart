// File: lib/elements/home/screens/permohonan_skrb_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:master_gambar/data/models/skrb.dart';
import '../providers/page_state_provider.dart';
import '../providers/skrb_providers.dart';
import '../repository/skrb_repository.dart';
import '../widgets/skrb/permohonan_skrb_table.dart';
import '../widgets/skrb/skrb_advanced_filter_panel.dart';

class PermohonanSkrbScreen extends ConsumerStatefulWidget {
  const PermohonanSkrbScreen({super.key});

  @override
  ConsumerState<PermohonanSkrbScreen> createState() =>
      _PermohonanSkrbScreenState();
}

class _PermohonanSkrbScreenState extends ConsumerState<PermohonanSkrbScreen> {
  SkrbAvailableTransaction? _selectedTransaction;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(skrbFilterProvider.notifier).state = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableAsync = ref.watch(availableTransactionsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(6.0, 0, 6.0, 0),
        child: Column(
          children: [
            // 1. Filter Lanjutan
            const SkrbAdvancedFilterPanel(),
            const SizedBox(height: 8),

            // 2. Baris Kontrol Ringkas (Judul, Dropdown, Tombol Buat, Refresh)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 12),
                const Text(
                  "Permohonan SKRB",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const Spacer(),

                // Dropdown Pilihan Transaksi Selesai
                SizedBox(
                  width: 710,
                  height: 32,
                  child: availableAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (err, stack) => Text(
                      'Error: $err',
                      style: const TextStyle(color: Colors.red, fontSize: 11),
                    ),
                    data: (list) => DropdownSearch<SkrbAvailableTransaction>(
                      items: (String filter, _) {
                        final query = filter.trim().toLowerCase();
                        if (query.isEmpty) {
                          return list.take(30).toList();
                        }
                        return list.where((item) {
                          return item.id.toLowerCase().contains(query) ||
                              item.customerName.toLowerCase().contains(query) ||
                              item.merk.toLowerCase().contains(query) ||
                              item.typeChassis.toLowerCase().contains(query);
                        }).toList();
                      },
                      itemAsString: (item) =>
                          '${item.id} - ${item.customerName} (${item.merk} ${item.typeChassis})',
                      compareFn: (i1, i2) => i1.id == i2.id,
                      selectedItem: _selectedTransaction,
                      onChanged: (item) {
                        setState(() => _selectedTransaction = item);
                      },
                      decoratorProps: DropDownDecoratorProps(
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: 'Pilih Transaksi (ID DWG / Customer)...',
                          labelStyle: const TextStyle(fontSize: 11),
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
                                'Ketik untuk mencari seluruh ID DWG / Customer...',// 30 list
                            hintStyle: TextStyle(fontSize: 11),
                            prefixIcon: Icon(Icons.search, size: 18),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                        ),
                        itemBuilder: (ctx, item, isSel, isDis) => ListTile(
                          dense: true,
                          title: Text(
                            '${item.id} - ${item.customerName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          subtitle: Text(
                            '${item.merk} ${item.typeChassis} (${item.jenisKendaraan}) | Pengajuan: ${item.jenisPengajuan}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Tombol Buat SKRB
                ElevatedButton.icon(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add, size: 16),
                  label: const Text(
                    'BUAT PERMOHONAN SKRB',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onPressed: (_selectedTransaction == null || _isLoading)
                      ? null
                      : () => _handleCreateSkrb(),
                ),
                const SizedBox(width: 8),

                // Reload Button
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  tooltip: 'Refresh Data',
                  onPressed: () {
                    setState(() {
                      _selectedTransaction = null;
                    });
                    ref.invalidate(skrbListProvider);
                    ref.invalidate(availableTransactionsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Memuat ulang tabel SKRB dan daftar transaksi...',
                        ),
                        duration: Duration(milliseconds: 1200),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
              ],
            ),
            const SizedBox(height: 8),

            // 3. Tabel Permohonan SKRB
            const Expanded(
              child: Card(
                child: SizedBox(
                  width: double.infinity,
                  child: PermohonanSkrbTable(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCreateSkrb() async {
    if (_selectedTransaction == null) return;

    setState(() => _isLoading = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Harap tunggu sebentar...\nMembuat Permohonan SKRB Baru',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final repository = ref.read(skrbRepositoryProvider);
      final newSkrb = await repository.createSkrb(_selectedTransaction!.id);

      ref.invalidate(skrbListProvider);
      ref.invalidate(availableTransactionsProvider);

      if (mounted) {
        Navigator.of(context).pop(); // Tutup loading dialog
        
        if (newSkrb.alreadyExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'SKRB untuk Transaksi ini sudah pernah dibuat sebelumnya (${newSkrb.idSkrb}).\nMengalihkan Anda ke halaman Detail SKRB tersebut.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.blue.shade700,
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (newSkrb.idSkrb.contains('-SKRB') && newSkrb.idSkrb.contains('/x')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Permohonan SKRB dibuat dengan ID sementara: ${newSkrb.idSkrb}\nPERHATIAN: "permohonan skrb" Customer belum ditambahkan admin! Segera minta admin untuk update.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.orange.shade800,
              duration: const Duration(seconds: 10),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Permohonan SKRB berhasil dibuat: ${newSkrb.idSkrb}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

      // Navigasi otomatis masuk langsung ke screen DETAIL SKRB
      ref.invalidate(skrbDetailProvider(newSkrb.id));
      ref.read(pageStateProvider.notifier).state = PageState(
        pageIndex: 3,
        skrbId: newSkrb.id,
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Tutup loading dialog jika error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat SKRB: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
