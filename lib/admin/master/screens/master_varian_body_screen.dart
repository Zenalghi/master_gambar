// File: lib/admin/master/screens/master_varian_body_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
// import '../repository/master_data_repository.dart';
import '../widgets/g-varian/varian_body_table.dart';
import '../widgets/g-varian/add_varian_body_form.dart';
import '../widgets/recycle_bin/varian_body_recycle_bin.dart';

class MasterVarianBodyScreen extends ConsumerStatefulWidget {
  const MasterVarianBodyScreen({super.key});

  @override
  ConsumerState<MasterVarianBodyScreen> createState() =>
      _MasterVarianBodyScreenState();
}

class _MasterVarianBodyScreenState
    extends ConsumerState<MasterVarianBodyScreen> {
  int _refreshToken = 0;
  final _searchController = TextEditingController();
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    // --- RESET OTOMATIS SAAT MASUK HALAMAN ---
    Future.microtask(() {
      // 1. Reset Filter Tabel (Search & Sort)
      ref.invalidate(varianBodyFilterProvider);

      // 2. Reset Cache Dropdown Master Data (agar data baru dari menu Master Data masuk)
      ref.invalidate(masterDataOptionsProvider);
      ref.read(selectedMasterDataFilterProvider.notifier).state = null;
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetSearchAndRefresh() {
    _searchController.clear();
    ref.invalidate(varianBodyFilterProvider);
    ref.invalidate(masterVarianOptionsFamilyProvider);
    ref.invalidate(masterDataOptionsProvider);
    ref.read(selectedMasterDataFilterProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: Judul & Kontrol
          Row(
            children: [
              const SizedBox(width: 10),
              const Text(
                'Manajemen Varian Body',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              /*
              SizedBox(
                height: 33,
                child: OutlinedButton.icon(
                  onPressed: (_isExporting || _isImporting)
                      ? null
                      : () async {
                          setState(() => _isExporting = true);
                          try {
                            final path = await ref
                                .read(masterDataRepositoryProvider)
                                .exportVarianBodyExcel();
                            if (path != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Export berhasil! File disimpan di: $path',
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Gagal export: ${e.toString()}',
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isExporting = false);
                          }
                        },
                  icon: _isExporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.file_download,
                          size: 18,
                          color: Colors.green,
                        ),
                  label: const Text(
                    'Export Excel',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 33,
                child: ElevatedButton.icon(
                  onPressed: (_isExporting || _isImporting)
                      ? null
                      : () async {
                          setState(() => _isImporting = true);
                          try {
                            final result = await ref
                                .read(masterDataRepositoryProvider)
                                .importVarianBodyExcel();
                            if (result != null && context.mounted) {
                              final msg =
                                  result['message'] ?? 'Import berhasil!';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(msg.toString()),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                              setState(() => _refreshToken++);
                              _resetSearchAndRefresh();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Gagal import: ${e.toString()}',
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isImporting = false);
                          }
                        },
                  icon: _isImporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.file_upload,
                          size: 18,
                          color: Colors.white,
                        ),
                  label: const Text(
                    'Import Excel',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
*/
              // Search Field
              SizedBox(
                width: 250,
                height: 31,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelStyle: TextStyle(fontSize: 14),
                    labelText: 'Search Varian...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => ref
                      .read(varianBodyFilterProvider.notifier)
                      .update((state) => {...state, 'search': value}),
                ),
              ),

              const SizedBox(width: 8),

              // Refresh Button
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
                onPressed: () {
                  setState(() => _refreshToken++);
                  _resetSearchAndRefresh();
                },
              ),

              const SizedBox(width: 8),

              // Recycle Bin Button
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.orange),
                tooltip: 'Recycle Bin (Data Dihapus)',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const VarianBodyRecycleBin(),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 1),

          // Widget Form Tambah
          AddVarianBodyForm(refreshToken: _refreshToken),

          const SizedBox(height: 5),

          // Widget Tabel Data
          const Expanded(child: VarianBodyTable()),
        ],
      ),
    );
  }
}
