// File: lib/admin/master/screens/master_gambar_kelistrikan_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/data/models/option_item.dart';
import '../widgets/add_gambar_kelistrikan_form.dart';
import '../widgets/gambar_kelistrikan_table.dart';

class MasterGambarKelistrikanScreen extends ConsumerStatefulWidget {
  const MasterGambarKelistrikanScreen({super.key});

  @override
  ConsumerState<MasterGambarKelistrikanScreen> createState() =>
      _MasterGambarKelistrikanScreenState();
}

class _MasterGambarKelistrikanScreenState
    extends ConsumerState<MasterGambarKelistrikanScreen> {
  bool _isUploading = false;

  // Counter untuk memaksa Form me-reset dirinya sendiri
  int _formResetKey = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _refreshAllData();
    });
  }

  // Method helper untuk Refresh Total
  void _refreshAllData() {
    // 1. Refresh Tabel
    ref.invalidate(gambarKelistrikanFilterProvider);

    // 2. Reset Mode Edit
    ref.read(editingKelistrikanFileProvider.notifier).state = null;

    // 3. Reset Data Copy-Paste
    ref.read(initialKelistrikanDataProvider.notifier).state = null;

    // 4. PENTING: Hapus Cache Dropdown agar data Engine/Merk/Chassis terbaru muncul
    ref.invalidate(mdTypeEngineOptionsProvider);
    ref.invalidate(mdMerkOptionsProvider);
    ref.invalidate(mdTypeChassisOptionsProvider);

    // 5. Paksa Form Input untuk Rebuild (Field jadi kosong)
    if (mounted) {
      setState(() {
        _formResetKey++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Data Copy Paste (Add Baru)
    final initialData = ref.watch(initialKelistrikanDataProvider);
    // Data Edit (Edit Lama)
    final editingItem = ref.watch(editingKelistrikanFileProvider);

    // Buka form jika ada data Copy Paste ATAU sedang Edit
    final bool shouldExpand = initialData != null || editingItem != null;

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
                'Manajemen File Kelistrikan',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SizedBox(
                width: 299,
                height: 31,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search (ID, Engine, Merk, Chassis)...',
                    labelStyle: TextStyle(fontSize: 11),
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => ref
                      .read(gambarKelistrikanFilterProvider.notifier)
                      .update((state) => {...state, 'search': value}),
                ),
              ),
              const SizedBox(width: 8),

              // --- TOMBOL REFRESH ---
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data & Reset Form',
                onPressed: _refreshAllData, // Panggil fungsi refresh total
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- FORM TAMBAH / EDIT (EXPANDABLE) ---
          ExpansionTile(
            key: ValueKey(
              'expansion_$shouldExpand',
            ), // Agar status expand responsif
            title: Text(
              editingItem != null
                  ? 'Edit File Kelistrikan'
                  : 'Upload File Kelistrikan Baru',
            ),
            initiallyExpanded: shouldExpand,
            children: [
              // Form Upload
              // KUNCI: ValueKey(_formResetKey) akan memaksa widget ini
              // dihancurkan dan dibuat baru saat _formResetKey berubah.
              AddGambarKelistrikanForm(
                key: ValueKey(_formResetKey),

                initialTypeEngine: initialData?['typeEngine'] as OptionItem?,
                initialMerk: initialData?['merk'] as OptionItem?,
                initialTypeChassis: initialData?['typeChassis'] as OptionItem?,
              ),
            ],
          ),

          // const SizedBox(height: 16),

          // --- TABEL DATA ---
          const Expanded(child: GambarKelistrikanTable()),
        ],
      ),
    );
  }
}
