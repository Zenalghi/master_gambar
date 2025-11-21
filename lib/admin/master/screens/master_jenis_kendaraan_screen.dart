// File: lib/admin/master/screens/master_jenis_kendaraan_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../repository/master_data_repository.dart';
import '../providers/master_data_providers.dart';
import '../widgets/jenis_kendaraan_table.dart';
import '../widgets/recycle_bin/jenis_kendaraan_recycle_bin.dart';

class MasterJenisKendaraanScreen extends ConsumerStatefulWidget {
  const MasterJenisKendaraanScreen({super.key});
  @override
  ConsumerState<MasterJenisKendaraanScreen> createState() =>
      _MasterJenisKendaraanScreenState();
}

class _MasterJenisKendaraanScreenState
    extends ConsumerState<MasterJenisKendaraanScreen> {
  final _jenisKendaraanController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    //buat pas buka halaman ini jadi 'search': ''
    ref
        .read(jenisKendaraanFilterProvider.notifier)
        .update((state) => {...state, 'search': ''});
    _jenisKendaraanController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await ref
          .read(masterDataRepositoryProvider)
          .addJenisKendaraan(
            // Tidak perlu typeChassisId lagi
            jenisKendaraan: _jenisKendaraanController.text,
          );
      _jenisKendaraanController.clear();
      // Refresh tabel via provider filter
      ref
          .read(jenisKendaraanFilterProvider.notifier)
          .update((state) => Map.from(state));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jenis Kendaraan berhasil ditambahkan!'),
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
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Manajemen Jenis Kendaraan',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),

              // Search Field
              SizedBox(
                width: 250,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Jenis Kendaraan...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => ref
                      .read(jenisKendaraanFilterProvider.notifier)
                      .update((state) => {...state, 'search': value}),
                ),
              ),
              const SizedBox(width: 8),
              // Refresh Button
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
                onPressed: () {
                  ref
                      .read(jenisKendaraanFilterProvider.notifier)
                      .update((state) => Map.from(state));
                  ref
                      .read(jenisKendaraanFilterProvider.notifier)
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
                    builder: (_) => const JenisKendaraanRecycleBin(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Form Input
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _jenisKendaraanController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Nama Jenis Kendaraan Baru',
                          hintText: 'Contoh: BAK BESI',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama jenis kendaraan tidak boleh kosong';
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
          const SizedBox(height: 16),
          const Expanded(child: JenisKendaraanTable()),
        ],
      ),
    );
  }
}
