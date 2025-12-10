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
  @override
  void initState() {
    super.initState();
    // Reset filter saat halaman dibuka
    Future.microtask(() {
      ref.invalidate(gambarKelistrikanFilterProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Cek apakah ada data "lemparan" dari Master Data (Fitur Copy & Navigate)
    final initialData = ref.watch(initialKelistrikanDataProvider);

    // Jika ada data lemparan, form harus terbuka otomatis
    final bool shouldExpand = initialData != null;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER & SEARCH ---
          Row(
            children: [
              const Text(
                'Manajemen File Kelistrikan (Gudang File)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SizedBox(
                width: 250,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search (ID, Engine, Merk, Chassis)...',
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
                tooltip: 'Refresh Data',
                onPressed: () {
                  ref
                      .read(gambarKelistrikanFilterProvider.notifier)
                      .update((state) => Map.from(state));

                  // Reset data copy-paste saat refresh manual
                  ref.read(initialKelistrikanDataProvider.notifier).state =
                      null;
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- FORM TAMBAH (EXPANDABLE) ---
          ExpansionTile(
            title: const Text('Upload File Kelistrikan Baru'),
            initiallyExpanded: shouldExpand,
            children: [
              // Form Upload dengan 3 Dropdown + File
              AddGambarKelistrikanForm(
                initialTypeEngine: initialData?['typeEngine'] as OptionItem?,
                initialMerk: initialData?['merk'] as OptionItem?,
                initialTypeChassis: initialData?['typeChassis'] as OptionItem?,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // --- TABEL DATA ---
          const Expanded(child: GambarKelistrikanTable()),
        ],
      ),
    );
  }
}
