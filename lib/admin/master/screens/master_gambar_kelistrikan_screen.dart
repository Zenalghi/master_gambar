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
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();

    // --- LOGIKA CERDAS DI SINI ---
    // Cek apakah ada data "titipan" atau sedang "edit" SAAT INI JUGA?
    final hasInitialData = ref.read(initialKelistrikanDataProvider) != null;
    final isEditing = ref.read(editingKelistrikanFileProvider) != null;

    // Jika ada data, langsung buka. Jika tidak, tutup.
    _isExpanded = hasInitialData || isEditing;
    // -----------------------------

    Future.microtask(() {
      // Refresh tabel tetap jalan, tapi jangan invalidate data provider di sini
      // karena akan menghapus data titipan tadi sebelum sempat dibaca form!
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
        // _isExpanded = false; // Tutup Form
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
        setState(() {
          _formResetKey++;
          _isExpanded = true;
        });
      }
    });

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
    String formTitle = 'Upload File Kelistrikan Baru';
    if (editingItem != null)
      formTitle = 'Edit File Kelistrikan';
    else if (initialData != null)
      formTitle = 'Upload File (Data Master)';
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
            // Key berubah jika status expand berubah -> memaksa UI update
            key: ValueKey('expansion_$_isExpanded'),
            initiallyExpanded: _isExpanded,
            onExpansionChanged: (val) => setState(() => _isExpanded = val),
            title: Text(
              formTitle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _isExpanded ? Theme.of(context).primaryColor : null,
              ),
            ),
            children: [
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
