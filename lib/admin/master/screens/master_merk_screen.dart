// File: lib/admin/master/screens/master_merk_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:dio/dio.dart';
import '../widgets/merk_table.dart';

class MasterMerkScreen extends ConsumerWidget {
  const MasterMerkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Manajemen Merk',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SizedBox(
                width: 250,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search Merk...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) => ref
                      .read(merkFilterProvider.notifier)
                      .update((state) => {...state, 'search': value}),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
                onPressed: () => ref
                    .read(merkFilterProvider.notifier)
                    .update((state) => Map.from(state)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // --- HAPUS DROPDOWN TYPE ENGINE ---
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Nama Merk Baru',
                        hintText: 'Contoh: HINO',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                    ),
                    onPressed: () async {
                      if (controller.text.isEmpty) return;
                      try {
                        await ref
                            .read(masterDataRepositoryProvider)
                            .addMerk(merk: controller.text); // Cuma kirim nama
                        controller.clear();
                        // Refresh tabel
                        ref
                            .read(merkFilterProvider.notifier)
                            .update((state) => Map.from(state));
                      } on DioException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error: ${e.response?.data['message']}',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Expanded(child: MerkTable()),
        ],
      ),
    );
  }
}
