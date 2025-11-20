// File: lib/admin/master/screens/master_varian_body_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import '../widgets/varian_body_table.dart';
import '../widgets/add_varian_body_form.dart'; // <-- Import widget baru

class MasterVarianBodyScreen extends ConsumerWidget {
  const MasterVarianBodyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Manajemen Varian Body',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SizedBox(
                width: 250,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Varian...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => ref
                      .read(varianBodyFilterProvider.notifier)
                      .update((state) => {...state, 'search': value}),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
                onPressed: () {
                  // Refresh tabel dan dropdown master data
                  ref
                      .read(varianBodyFilterProvider.notifier)
                      .update((state) => Map.from(state));
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Panggil Widget Form Baru
          const AddVarianBodyForm(),

          const SizedBox(height: 16),
          const Expanded(child: VarianBodyTable()),
        ],
      ),
    );
  }
}
