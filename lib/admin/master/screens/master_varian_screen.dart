//lib/admin/master/screens/master_varian_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/widgets/recycle_bin/master_varian_recycle_bin.dart';
import '../providers/master_data_providers.dart';
import '../widgets/e-master-varian/add_master_varian_form.dart';
import '../widgets/e-master-varian/master_varian_table.dart';

class MasterVarianScreen extends ConsumerStatefulWidget {
  const MasterVarianScreen({super.key});

  @override
  ConsumerState<MasterVarianScreen> createState() => _MasterVarianScreenState();
}

class _MasterVarianScreenState extends ConsumerState<MasterVarianScreen> {
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
