// File: lib/admin/master/screens/master_varian_body_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import '../widgets/varian_body_table.dart';
import '../widgets/add_varian_body_form.dart';
import '../widgets/recycle_bin/varian_body_recycle_bin.dart';

class MasterVarianBodyScreen extends ConsumerStatefulWidget {
  const MasterVarianBodyScreen({super.key});

  @override
  ConsumerState<MasterVarianBodyScreen> createState() =>
      _MasterVarianBodyScreenState();
}

class _MasterVarianBodyScreenState
    extends ConsumerState<MasterVarianBodyScreen> {
  @override
  void initState() {
    super.initState();
    // --- RESET OTOMATIS SAAT MASUK HALAMAN ---
    Future.microtask(() {
      // 1. Reset Filter Tabel (Search & Sort)
      ref.invalidate(varianBodyFilterProvider);

      // 2. Reset Cache Dropdown Master Data (agar data baru dari menu Master Data masuk)
      ref.invalidate(masterDataOptionsProvider);
    });
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
              SizedBox(width: 10),
              const Text(
                'Manajemen Varian Body',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const Spacer(),

              // Search Field
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
                  ref.invalidate(varianBodyFilterProvider);
                  ref.invalidate(masterDataOptionsProvider);
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
          const AddVarianBodyForm(),

          const SizedBox(height: 5),

          // Widget Tabel Data
          const Expanded(child: VarianBodyTable()),
        ],
      ),
    );
  }
}
