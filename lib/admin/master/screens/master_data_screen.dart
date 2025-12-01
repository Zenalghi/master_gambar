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
  @override
  void initState() {
    super.initState();
    // RESET TOTAL SAAT HALAMAN DIBUKA
    Future.microtask(() {
      // 1. Reset Search
      ref.invalidate(masterDataFilterProvider);

      // 2. Reset Cache Dropdown (Agar data baru dari menu A/B/C/D masuk)
      ref.invalidate(mdTypeEngineOptionsProvider);
      ref.invalidate(mdMerkOptionsProvider);
      ref.invalidate(mdTypeChassisOptionsProvider);
      ref.invalidate(mdJenisKendaraanOptionsProvider);

      // 3. Reset Copy Provider
      ref.read(masterDataToCopyProvider.notifier).state = null;
    });
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
              SizedBox(width: 10),
              const Text(
                'Manajemen Master Data (Kombinasi)',
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
                  ),
                  onChanged: (value) => ref
                      .read(masterDataFilterProvider.notifier)
                      .update((state) => {...state, 'search': value}),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
                onPressed: () {
                  // Refresh manual juga reset dropdown
                  ref.invalidate(mdTypeEngineOptionsProvider);
                  ref.invalidate(mdMerkOptionsProvider);
                  ref.invalidate(mdTypeChassisOptionsProvider);
                  ref.invalidate(mdJenisKendaraanOptionsProvider);
                  ref
                      .read(masterDataFilterProvider.notifier)
                      .update((state) => Map.from(state));
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.orange),
                tooltip: 'Recycle Bin',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const MasterDataRecycleBin(), // Widget baru
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 1),
          const AddMasterDataForm(),
          const SizedBox(height: 5),
          const Expanded(child: MasterDataTable()),
        ],
      ),
    );
  }
}
