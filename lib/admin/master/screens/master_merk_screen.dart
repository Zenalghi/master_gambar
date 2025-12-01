// File: lib/admin/master/screens/master_merk_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../widgets/merk_table.dart';
import '../providers/master_data_providers.dart';
import '../repository/master_data_repository.dart';
import '../widgets/recycle_bin/merk_recycle_bin.dart';

class MasterMerkScreen extends ConsumerStatefulWidget {
  const MasterMerkScreen({super.key});
  @override
  ConsumerState<MasterMerkScreen> createState() => _MasterMerkScreenState();
}

class _MasterMerkScreenState extends ConsumerState<MasterMerkScreen> {
  final _merkController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Kunci Form untuk validasi visual

  @override
  void initState() {
    super.initState();
    // --- RESET SEARCH & FILTER MERK ---
    // Ini akan mereset 'search' jadi kosong dan sort kembali ke default
    Future.microtask(() => ref.invalidate(merkFilterProvider));
  }

  @override
  void dispose() {
    _merkController.dispose();
    super.dispose();
  }

  void _submit() async {
    // 1. Validasi Form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await ref
          .read(masterDataRepositoryProvider)
          .addMerk(
            // Tidak perlu typeEngineId lagi karena independen
            merk: _merkController.text,
          );
      _merkController.clear();
      // Refresh tabel via provider filter
      ref.read(merkFilterProvider.notifier).update((state) => Map.from(state));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Merk berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.response?.data['message'] ?? e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
              SizedBox(width: 10),
              const Text(
                'Manajemen Merk',
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
                    labelText: 'Search Merk...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => ref
                      .read(merkFilterProvider.notifier)
                      .update((state) => {...state, 'search': value}),
                ),
              ),
              const SizedBox(width: 8),
              // Refresh Button
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
                onPressed: () {
                  // Trigger refresh pada DataSource
                  ref
                      .read(merkFilterProvider.notifier)
                      .update((state) => Map.from(state));
                  ref
                      .read(merkFilterProvider.notifier)
                      .update((state) => {...state, 'search': ''});
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
                    builder: (_) => const MerkRecycleBin(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 1),
          // Form Input
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        style: const TextStyle(fontSize: 14),
                        controller: _merkController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelStyle: TextStyle(fontSize: 14),
                          labelText: 'Nama Merk Baru',
                          hintText: 'Contoh: HINO',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama merk tidak boleh kosong';
                          }
                          return null;
                        },
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
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Expanded(child: MerkTable()),
        ],
      ),
    );
  }
}
