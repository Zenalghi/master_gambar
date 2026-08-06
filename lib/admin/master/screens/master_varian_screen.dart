//lib/admin/master/screens/master_varian_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/widgets/recycle_bin/master_varian_recycle_bin.dart';
import '../providers/master_data_providers.dart';
import '../repository/master_data_repository.dart';
import '../widgets/e-master-varian/add_master_varian_form.dart';
import '../widgets/e-master-varian/master_varian_table.dart';

class MasterVarianScreen extends ConsumerStatefulWidget {
  const MasterVarianScreen({super.key});

  @override
  ConsumerState<MasterVarianScreen> createState() => _MasterVarianScreenState();
}

class _MasterVarianScreenState extends ConsumerState<MasterVarianScreen> {
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    // Reset pencarian & filter saat masuk halaman
    Future.microtask(() {
      ref.invalidate(masterVarianFilterProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER & SEARCH ---
          Row(
            children: [
              const SizedBox(width: 10),
              const Text(
                'Data Master Varian',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
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
                                .exportMasterVarianExcel();
                            if (path != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Export berhasil! File disimpan di: $path'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal export: ${e.toString()}'),
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
                      : const Icon(Icons.file_download, size: 18, color: Colors.green),
                  label: const Text(
                    'Export Excel',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
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
                                .importMasterVarianExcel();
                            if (result != null && context.mounted) {
                              final msg = result['message'] ?? 'Import berhasil!';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(msg.toString()),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                              ref.invalidate(masterVarianFilterProvider);
                              ref.invalidate(varianBodyFilterProvider);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal import: ${e.toString()}'),
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
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.file_upload, size: 18, color: Colors.white),
                  label: const Text(
                    'Import Excel',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 250,
                height: 31,
                child: TextField(
                  decoration: const InputDecoration(
                    labelStyle: TextStyle(fontSize: 14),
                    labelText: 'Search Varian...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => ref
                      .read(masterVarianFilterProvider.notifier)
                      .update((state) => {...state, 'search': value}),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
                onPressed: () {
                  ref.invalidate(masterVarianFilterProvider);
                },
              ),
              const SizedBox(width: 8),
              // Tombol Recycle Bin bisa ditambahkan nanti jika ada view khusus
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.orange),
                tooltip: 'Recycle Bin (Data Dihapus)',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const MasterVarianRecycleBin(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 1),

          // --- FORM TAMBAH ---
          const AddMasterVarianForm(),

          const SizedBox(height: 5),

          // --- TABEL DATA ---
          const Expanded(child: MasterVarianTable()),
        ],
      ),
    );
  }
}
