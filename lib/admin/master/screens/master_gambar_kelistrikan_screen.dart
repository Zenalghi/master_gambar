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
  // Key untuk memaksa rebuild form saat data baru masuk / reset
  int _formResetKey = 0;
  // State lokal untuk mengontrol ExpansionTile
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.invalidate(gambarKelistrikanFilterProvider);
    });
  }

  void _handleRefresh() {
    ref.invalidate(gambarKelistrikanFilterProvider);
    ref.read(initialKelistrikanDataProvider.notifier).state = null;
    ref.read(editingKelistrikanFileProvider.notifier).state = null;

    // Invalidate Dropdown Caches
    ref.invalidate(mdTypeEngineOptionsProvider);
    ref.invalidate(mdMerkOptionsProvider);
    ref.invalidate(mdTypeChassisOptionsProvider);

    if (mounted) {
      setState(() {
        _formResetKey++; // Reset Form jadi kosong
        _isExpanded = true; // Tutup Form
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // DENGARKAN JIKA ADA DATA "LEMPARAN" DARI MASTER DATA
    ref.listen<Map<String, dynamic>?>(initialKelistrikanDataProvider, (
      previous,
      next,
    ) {
      if (next != null) {
        // Jika ada data baru masuk, paksa form rebuild dengan data baru & buka expand
        setState(() {
          _formResetKey++;
          _isExpanded = true;
        });
      }
    });

    // DENGARKAN JIKA MODE EDIT AKTIF
    ref.listen(editingKelistrikanFileProvider, (previous, next) {
      if (next != null) {
        setState(() {
          _formResetKey++;
          _isExpanded = true;
        });
      }
    });

    final initialData = ref.watch(initialKelistrikanDataProvider);
    final editingItem = ref.watch(editingKelistrikanFileProvider);

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER ---
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
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data & Reset Form',
                onPressed: _handleRefresh,
              ),
            ],
          ),
          // const SizedBox(height: 16),

          // --- FORM TAMBAH / EDIT ---
          ExpansionTile(
            key: ValueKey(
              'expansion_$_isExpanded',
            ), // Agar status expand responsif secara programatis
            initiallyExpanded: _isExpanded,
            onExpansionChanged: (val) => setState(() => _isExpanded = val),
            title: Text(
              editingItem != null
                  ? 'Edit File Kelistrikan'
                  : 'Upload File Kelistrikan Baru',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            children: [
              AddGambarKelistrikanForm(
                // KUNCI: Key berubah = Form Rebuild ulang (baca data initial baru)
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
