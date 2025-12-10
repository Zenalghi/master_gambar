// File: lib/admin/master/screens/master_data_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import '../widgets/add_master_data_form.dart';
import '../widgets/master_data_table.dart';
import '../widgets/recycle_bin/master_data_recycle_bin.dart';

class MasterDataScreen extends ConsumerStatefulWidget {
  const MasterDataScreen({super.key});

  @override
  ConsumerState<MasterDataScreen> createState() => _MasterDataScreenState();
}

class _MasterDataScreenState extends ConsumerState<MasterDataScreen> {
  int _formResetKey = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.invalidate(masterDataFilterProvider));
  }

  void _handleReload() {
    // Trigger update untuk tabel
    ref
        .read(masterDataFilterProvider.notifier)
        .update(
          (state) => {
            ...state,
            'last_update': DateTime.now().millisecondsSinceEpoch
                .toString(), // Trigger paksa
          },
        );

    // Bersihkan cache dropdown
    ref.invalidate(mdTypeEngineOptionsProvider);
    ref.invalidate(mdMerkOptionsProvider);
    ref.invalidate(mdTypeChassisOptionsProvider);
    ref.invalidate(mdJenisKendaraanOptionsProvider);

    // Reset Form Input
    if (mounted) {
      setState(() {
        _formResetKey++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 10),
              const Text(
                'Manajemen Master Data',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SizedBox(
                width: 250,
                height: 31,
                child: TextField(
                  decoration: const InputDecoration(
                    labelStyle: TextStyle(fontSize: 14),
                    labelText: 'Search...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => ref
                      .read(masterDataFilterProvider.notifier)
                      .update((state) => {...state, 'search': value}),
                ),
              ),
              const SizedBox(width: 8),

              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data & Reset Form',
                onPressed: _handleReload,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.orange),
                tooltip: 'Lihat Data Terhapus (Trash)',
                onPressed: () async {
                  // Tunggu sampai dialog ditutup
                  await showDialog(
                    context: context,
                    builder: (_) => const MasterDataRecycleBin(),
                    barrierDismissible: true,
                  );

                  // SETELAH DIALOG TUTUP, REFRESH TABEL UTAMA
                  // Ini penting agar data yang di-restore muncul kembali
                  ref
                      .read(masterDataFilterProvider.notifier)
                      .update(
                        (state) => {
                          ...state,
                          'last_update': DateTime.now().millisecondsSinceEpoch
                              .toString(),
                        },
                      );

                  // Invalidate cache dropdown juga jika perlu
                  ref.invalidate(mdTypeEngineOptionsProvider);
                },
              ),
            ],
          ),
          const SizedBox(height: 1),

          AddMasterDataForm(key: ValueKey(_formResetKey)),

          const SizedBox(height: 5),
          const Expanded(child: MasterDataTable()),
        ],
      ),
    );
  }
}
