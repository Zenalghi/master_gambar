//lib\admin\master\screens\master_type_engine_screen.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:master_gambar/app/core/notifiers/refresh_notifier.dart';
import '../widgets/a-type/type_engine_table.dart';
import '../providers/master_data_providers.dart';
import '../repository/master_data_repository.dart';
import '../widgets/recycle_bin/type_engine_recycle_bin.dart';

class MasterTypeEngineScreen extends ConsumerStatefulWidget {
  const MasterTypeEngineScreen({super.key});

  @override
  ConsumerState<MasterTypeEngineScreen> createState() =>
      _MasterTypeEngineScreenState();
}

class _MasterTypeEngineScreenState
    extends ConsumerState<MasterTypeEngineScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Kunci Validasi
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(typeEngineSearchQueryProvider.notifier).state = '';
      _searchController.clear();
      ref.invalidate(typeEngineListProvider);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _refreshTypeEngine() {
    _searchController.clear();
    ref.read(typeEngineSearchQueryProvider.notifier).state = '';
    ref.invalidate(typeEngineListProvider);
    ref.read(refreshNotifierProvider.notifier).refresh();
  }

  void _submit() async {
    // 1. Validasi Form (Menangani Field Kosong)
    if (!_formKey.currentState!.validate()) {
      return; // Jika tidak valid, berhenti dan munculkan pesan error di bawah text field
    }

    try {
      await ref
          .read(masterDataRepositoryProvider)
          .addTypeEngine(typeEngine: _controller.text);

      _controller.clear();
      ref.invalidate(typeEngineListProvider);

      // 2. Tampilkan Notifikasi Sukses
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.response?.data['message'] ?? e.message}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
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
                'Manajemen Type Engine',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SizedBox(
                width: 250,
                height: 31,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelStyle: TextStyle(fontSize: 14),
                    labelText: 'Search Type Engine...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) =>
                      ref.read(typeEngineSearchQueryProvider.notifier).state =
                          value,
                ),
              ),
              const SizedBox(width: 8),
              // Tombol Refresh
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
                onPressed: _refreshTypeEngine,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.orange),
                tooltip: 'Recycle Bin (Data Dihapus)',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const TypeEngineRecycleBin(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 1),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                // Bungkus dengan Form
                key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        style: const TextStyle(fontSize: 14),
                        controller: _controller,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelStyle: TextStyle(fontSize: 14),
                          labelText: 'Nama Type Engine Baru',
                          hintText: 'Contoh: EURO 4',
                        ),
                        // Tambahkan Validator
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama tidak boleh kosong';
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
          const Expanded(child: TypeEngineTable()),
        ],
      ),
    );
  }
}
